import 'dart:convert';
import 'dart:io';

import 'package:cv_flutter_johgrace/data/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiService API contract', () {
    test('uses documented routes, methods, headers, and JSON fields', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') {
          return _jsonResponse(200, {
            'success': true,
            'data': [
              _memberJson(
                imageUrl: 'http://localhost/api-test/public/uploads/famille/photo.png',
              ),
            ],
          });
        }
        return _jsonResponse(request.method == 'DELETE' ? 200 : 201, {
          'success': true,
          'data': {'id': 42},
        });
      });
      final api = ApiService(
        baseUri: Uri.parse('http://10.0.2.2:8080/api-test/public'),
        client: client,
      );
      addTearDown(api.close);

      final registration = await api.register('test@example.com', 'secret123');
      final login = await api.login('test@example.com', 'secret123');
      final members = await api.getFamilyMembers();
      await api.createFamilyMember(_validMember());
      await api.updateFamilyMember(42, _validMember());
      await api.deleteFamilyMember(42);

      expect(registration, {'id': 42});
      expect(login, {'id': 42});
      expect(members.single.fullName, 'Papa Bigega Baraka');
      expect(
        members.single.imageUrl,
        'http://10.0.2.2:8080/api-test/public/uploads/famille/photo.png',
      );

      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'POST /api-test/public/accounts/register',
          'POST /api-test/public/accounts/login',
          'GET /api-test/public/famille-membres',
          'POST /api-test/public/famille-membres',
          'PUT /api-test/public/famille-membres/42',
          'DELETE /api-test/public/famille-membres/42',
        ],
      );
      for (final request in [
        requests[0],
        requests[1],
        requests[3],
        requests[4],
      ]) {
        expect(request.headers['content-type'], 'application/json');
      }
      expect(jsonDecode(requests[0].body), {
        'email': 'test@example.com',
        'password': 'secret123',
      });
      expect(jsonDecode(requests[1].body), {
        'email': 'test@example.com',
        'password': 'secret123',
      });
      expect(jsonDecode(requests[3].body), _validMember());
      expect(jsonDecode(requests[4].body), _validMember());
    });

    test(
      'uses the Android emulator host when no base URL is provided',
      () async {
        final previousPlatform = debugDefaultTargetPlatformOverride;
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = previousPlatform;
        });
        Uri? requestedUri;
        final api = ApiService(
          client: MockClient((request) async {
            requestedUri = request.url;
            return _jsonResponse(200, {
              'success': true,
              'data': {'id': 1},
            });
          }),
        );
        addTearDown(api.close);

        await api.login('test@example.com', 'secret123');

        expect(requestedUri?.host, '10.0.2.2');
        expect(requestedUri?.path, '/api-test/public/accounts/login');
      },
    );

    test(
      'uploads a primary photo as multipart and enforces the 2 MB limit',
      () async {
        http.MultipartRequest? multipartRequest;
        final api = ApiService(
          baseUri: Uri.parse('http://localhost/api-test/public'),
          client: MockClient.streaming((request, bodyStream) async {
            multipartRequest = request as http.MultipartRequest;
            await bodyStream.toBytes();
            return _streamedResponse(
              _jsonResponse(201, {
                'success': true,
                'data': {'id': 42},
              }),
            );
          }),
        );
        addTearDown(api.close);

        await api.createFamilyMember(
          _validMember(),
          imageBytes: Uint8List.fromList([1, 2, 3]),
          imageFilename: 'photo.jpg',
        );

        expect(multipartRequest?.fields, _validMember());
        expect(multipartRequest?.files.single.field, 'image');
        expect(multipartRequest?.files.single.filename, 'photo.jpg');
        expect(multipartRequest?.files.single.length, 3);

        var requestSent = false;
        final oversizedApi = ApiService(
          baseUri: Uri.parse('http://localhost/api-test/public'),
          client: MockClient((_) async {
            requestSent = true;
            return _jsonResponse(201, {'success': true, 'data': null});
          }),
        );
        addTearDown(oversizedApi.close);

        await expectLater(
          oversizedApi.createFamilyMember(
            _validMember(),
            imageBytes: Uint8List(ApiService.maxFamilyMemberImageBytes + 1),
          ),
          throwsA(
            isA<ApiException>().having(
              (error) => error.message,
              'message',
              contains('limite de 2 Mo'),
            ),
          ),
        );
        expect(requestSent, isFalse);
      },
    );

    test('preserves API errors and validation details', () async {
      final api = ApiService(
        baseUri: Uri.parse('http://localhost/api-test/public'),
        client: MockClient((_) async {
          return _jsonResponse(422, {
            'success': false,
            'message': 'Données invalides',
            'errors': {'nom': 'Le champ nom est obligatoire'},
          });
        }),
      );
      addTearDown(api.close);

      await expectLater(
        api.createFamilyMember(_validMember()),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Données invalides (nom: Le champ nom est obligatoire)',
          ),
        ),
      );
    });

    test('surfaces the documented login and registration errors', () async {
      final api = ApiService(
        baseUri: Uri.parse('http://localhost/api-test/public'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/accounts/login')) {
            return _jsonResponse(401, {
              'success': false,
              'message': 'Email ou mot de passe incorrect',
            });
          }
          return _jsonResponse(409, {
            'success': false,
            'message': 'Cet email est déjà utilisé',
          });
        }),
      );
      addTearDown(api.close);

      await expectLater(
        api.login('test@example.com', 'incorrect'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Email ou mot de passe incorrect',
          ),
        ),
      );
      await expectLater(
        api.register('test@example.com', 'secret123'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Cet email est déjà utilisé',
          ),
        ),
      );
    });

    test(
      'reports HTTP status when the server error body is not JSON',
      () async {
        final api = ApiService(
          baseUri: Uri.parse('http://localhost/api-test/public'),
          client: MockClient(
            (_) async => http.Response('Internal Server Error', 500),
          ),
        );
        addTearDown(api.close);

        await expectLater(
          api.getFamilyMembers(),
          throwsA(
            isA<ApiException>().having(
              (error) => error.message,
              'message',
              'Erreur du serveur (500).',
            ),
          ),
        );
      },
    );

    test('reports malformed successful responses and network errors', () async {
      final invalidJsonApi = ApiService(
        baseUri: Uri.parse('http://localhost/api-test/public'),
        client: MockClient((_) async => http.Response('not-json', 200)),
      );
      addTearDown(invalidJsonApi.close);
      await expectLater(
        invalidJsonApi.getFamilyMembers(),
        throwsA(isA<ApiException>()),
      );

      final offlineApi = ApiService(
        baseUri: Uri.parse('http://localhost/api-test/public'),
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      addTearDown(offlineApi.close);
      await expectLater(
        offlineApi.getFamilyMembers(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('Impossible de joindre l’API'),
          ),
        ),
      );
    });
  });
}

Map<String, dynamic> _memberJson({String? imageUrl}) => {
  'id': 42,
  'nom': 'Baraka',
  'postnom': 'Bigega',
  'prenom': 'Papa',
  'lieu_naissance': 'Goma',
  'date_naissance': '1970-05-12',
  'parente': 'Père',
  'image_url': imageUrl,
};

Map<String, String> _validMember() => {
  'nom': 'Baraka',
  'postnom': 'Bigega',
  'prenom': 'Papa',
  'lieu_naissance': 'Goma',
  'date_naissance': '1970-05-12',
  'parente': 'Père',
};

http.Response _jsonResponse(int statusCode, Map<String, dynamic> data) =>
    http.Response(jsonEncode(data), statusCode);

Future<http.StreamedResponse> _streamedResponse(http.Response response) async =>
    http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
