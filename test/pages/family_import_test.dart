import 'dart:convert';

import 'package:cv_flutter_johgrace/data/api_service.dart';
import 'package:cv_flutter_johgrace/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'validates, reviews, uploads sequentially, and resumes after an API error',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final members = <Map<String, dynamic>>[];
      final createRequests = <http.MultipartRequest>[];
      var createCount = 0;
      final apiService = ApiService(
        baseUri: Uri.parse('http://localhost/api-test/public'),
        client: MockClient.streaming((request, bodyStream) async {
          await bodyStream.toBytes();
          if (request.url.path.endsWith('/accounts/login')) {
            return _streamedResponse(
              _response(200, {
                'success': true,
                'data': {'id': 1},
              }),
            );
          }
          if (request.url.path.endsWith('/famille-membres')) {
            if (request.method == 'GET') {
              return _streamedResponse(
                _response(200, {'success': true, 'data': members}),
              );
            }
            if (request is http.MultipartRequest) {
              createCount++;
              createRequests.add(request);
              if (createCount == 2) {
                return _streamedResponse(
                  _response(500, {
                    'success': false,
                    'message': 'Serveur indisponible',
                  }),
                );
              }
              final member = {...request.fields, 'id': 2, 'image_url': null};
              members.add(member);
              return _streamedResponse(
                _response(201, {'success': true, 'data': member}),
              );
            }
          }
          return _streamedResponse(
            _response(404, {'success': false, 'message': 'Introuvable'}),
          );
        }),
      );
      addTearDown(apiService.close);

      await _openFamilyPage(tester, apiService);
      expect(find.text('Ancien membre 1 sur 6'), findsOneWidget);
      expect(find.text('Mitila Linda Harmonie'), findsNothing);
      await tester.tap(find.text('Importer ce membre'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(6));
      for (var index = 0; index < 6; index++) {
        expect(
          tester.widget<TextFormField>(fields.at(index)).controller!.text,
          isEmpty,
        );
      }

      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(find.text('Ce champ est obligatoire.'), findsNWidgets(6));
      expect(createCount, 0);

      await _enterMemberDetails(tester, fields, const [
        'N',
        'Annonciate',
        'Maman',
        '1975-02-14',
        'Goma',
        'Mère',
      ]);
      await tester.enterText(fields.at(0), 'N' * 51);
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(find.text('Maximum 50 caractères.'), findsOneWidget);
      expect(createCount, 0);

      await tester.enterText(fields.at(0), 'Matakio');
      await tester.enterText(fields.at(3), '2024-02-31');
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(find.text('Utilisez le format AAAA-MM-JJ.'), findsOneWidget);
      await tester.enterText(fields.at(3), '9999-01-01');
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(
        find.text('La date ne peut pas être dans le futur.'),
        findsOneWidget,
      );
      expect(createCount, 0);

      await tester.enterText(fields.at(3), '1975-02-14');
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(find.text('Vérifier avant l’importation'), findsOneWidget);
      expect(find.text('Nom : Matakio'), findsOneWidget);
      expect(find.text('Date de naissance : 1975-02-14'), findsOneWidget);
      expect(find.text('Photo principale : envoyée'), findsOneWidget);
      expect(createCount, 0);

      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      expect(createCount, 1);
      expect(createRequests.first.fields, {
        'nom': 'Matakio',
        'postnom': 'Annonciate',
        'prenom': 'Maman',
        'date_naissance': '1975-02-14',
        'lieu_naissance': 'Goma',
        'parente': 'Mère',
      });
      expect(createRequests.first.files.single.field, 'image');
      expect(
        createRequests.first.files.single.length,
        lessThanOrEqualTo(ApiService.maxFamilyMemberImageBytes),
      );

      expect(find.text('Étape : Mitila Linda Harmonie'), findsOneWidget);
      await _enterMemberDetails(tester, find.byType(TextFormField), const [
        'Mitila',
        'Linda',
        'Harmonie',
        '1990-01-01',
        'Goma',
        'Sœur',
      ]);
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importer'));
      await tester.pumpAndSettle();

      expect(createCount, 2);
      expect(find.text('Échec — Serveur indisponible'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('Matakio Annonciate'), findsOneWidget);
      expect(find.text('Importé'), findsOneWidget);
      await tester.tap(find.text('Réessayer cet import'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'Mitila',
      );
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(createCount, 2);
    },
  );

  testWidgets('blocks an exact duplicate found in the refreshed API list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final members = <Map<String, dynamic>>[
      _apiMember(id: 8, nom: 'Matakio', postnom: 'Annonciate', prenom: 'Maman'),
    ];
    var createCount = 0;
    final apiService = ApiService(
      baseUri: Uri.parse('http://localhost/api-test/public'),
      client: MockClient.streaming((request, bodyStream) async {
        await bodyStream.toBytes();
        if (request.url.path.endsWith('/accounts/login')) {
          return _streamedResponse(
            _response(200, {
              'success': true,
              'data': {'id': 1},
            }),
          );
        }
        if (request.url.path.endsWith('/famille-membres')) {
          if (request.method == 'GET') {
            return _streamedResponse(
              _response(200, {'success': true, 'data': members}),
            );
          }
          createCount++;
        }
        return _streamedResponse(
          _response(201, {'success': true, 'data': null}),
        );
      }),
    );
    addTearDown(apiService.close);

    await _openFamilyPage(tester, apiService);
    await tester.tap(find.text('Importer ce membre'));
    await tester.pumpAndSettle();
    await _enterMemberDetails(tester, find.byType(TextFormField), const [
      'Matakio',
      'Annonciate',
      'Maman',
      '1975-02-14',
      'Goma',
      'Mère',
    ]);
    await tester.tap(find.text('Importer'));
    await tester.pumpAndSettle();

    expect(find.text('Vérifier avant l’importation'), findsNothing);
    expect(createCount, 0);
    expect(find.text('Étape : Mitila Linda Harmonie'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Matakio Annonciate'), findsOneWidget);
    expect(find.text('Déjà présent dans l’API'), findsOneWidget);
  });

  testWidgets('requires manual review for a partial name match', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final members = <Map<String, dynamic>>[
      _apiMember(id: 8, nom: 'Matakio', postnom: 'Annonciate', prenom: 'Autre'),
    ];
    final apiService = ApiService(
      baseUri: Uri.parse('http://localhost/api-test/public'),
      client: MockClient.streaming((request, bodyStream) async {
        await bodyStream.toBytes();
        if (request.url.path.endsWith('/accounts/login')) {
          return _streamedResponse(
            _response(200, {
              'success': true,
              'data': {'id': 1},
            }),
          );
        }
        return _streamedResponse(
          _response(200, {'success': true, 'data': members}),
        );
      }),
    );
    addTearDown(apiService.close);

    await _openFamilyPage(tester, apiService);
    await tester.tap(find.text('Importer ce membre'));
    await tester.pumpAndSettle();
    await _enterMemberDetails(tester, find.byType(TextFormField), const [
      'Autre',
      'Personne',
      'Distincte',
      '1975-02-14',
      'Goma',
      'Mère',
    ]);
    await tester.tap(find.text('Importer'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Correspondance possible à vérifier manuellement'),
      findsOneWidget,
    );
    expect(find.textContaining('Autre Annonciate Matakio'), findsNWidgets(2));
    expect(find.text('Importer quand même'), findsOneWidget);
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.text('Étape : Mitila Linda Harmonie'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Matakio Annonciate'), findsOneWidget);
    expect(find.text('Passé'), findsOneWidget);
  });
}

Future<void> _openFamilyPage(WidgetTester tester, ApiService apiService) async {
  await tester.pumpWidget(CvFlutterApp(apiService: apiService));
  await tester.enterText(find.byType(TextFormField).first, 'demo@example.com');
  await tester.enterText(find.byType(TextFormField).last, 'secret123');
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ma famille').last);
  await tester.pumpAndSettle();
}

Future<void> _enterMemberDetails(
  WidgetTester tester,
  Finder fields,
  List<String> values,
) async {
  for (var index = 0; index < values.length; index++) {
    await tester.enterText(fields.at(index), values[index]);
  }
}

Map<String, dynamic> _apiMember({
  required int id,
  required String nom,
  required String postnom,
  required String prenom,
}) => {
  'id': id,
  'nom': nom,
  'postnom': postnom,
  'prenom': prenom,
  'lieu_naissance': 'Goma',
  'date_naissance': '1975-02-14',
  'parente': 'Mère',
  'image_url': null,
};

http.Response _response(int statusCode, Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), statusCode);

Future<http.StreamedResponse> _streamedResponse(http.Response response) async =>
    http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
