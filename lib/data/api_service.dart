import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'family_member.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({Uri? baseUri, http.Client? client})
    : _baseUri = _withTrailingSlash(baseUri ?? Uri.parse(_configuredBaseUrl)),
      _client = client ?? http.Client();

  static const _environmentBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get _configuredBaseUrl {
    if (_environmentBaseUrl.isNotEmpty) return _environmentBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/api-test/public';
    }
    return 'http://localhost/api-test/public';
  }

  final Uri _baseUri;
  final http.Client _client;

  static const maxFamilyMemberImageBytes = 2 * 1024 * 1024;

  static Uri _withTrailingSlash(Uri uri) {
    final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: path);
  }

  Uri _endpoint(String path) => _baseUri.resolve(path);

  Future<Map<String, dynamic>> login(String email, String password) {
    return _postJson('accounts/login', {'email': email, 'password': password});
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    final data = await _request('GET', 'famille-membres');
    if (data is! List) {
      throw const ApiException('La réponse de l’API est invalide.');
    }
    return data
        .map(
          (item) => FamilyMember.fromJson(
            item as Map<String, dynamic>,
            baseUri: _baseUri,
          ),
        )
        .toList();
  }

  Future<void> createFamilyMember(
    Map<String, String> member, {
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    if (imageBytes != null) {
      if (imageBytes.length > maxFamilyMemberImageBytes) {
        throw const ApiException(
          'La photo principale dépasse la limite de 2 Mo. '
          'Désactivez son envoi et réessayez.',
        );
      }
      await _requestMultipart(
        'famille-membres',
        member,
        imageBytes,
        imageFilename ?? 'photo.jpg',
      );
      return;
    }
    await _request('POST', 'famille-membres', body: member);
  }

  Future<void> updateFamilyMember(int id, Map<String, String> member) async {
    await _request('PUT', 'famille-membres/$id', body: member);
  }

  Future<void> deleteFamilyMember(int id) async {
    await _request('DELETE', 'famille-membres/$id');
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, String> body,
  ) async {
    final data = await _request('POST', path, body: body);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('La réponse de l’API est invalide.');
    }
    return data;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = _endpoint(path);
    try {
      final response = switch (method) {
        'GET' => await _client.get(uri).timeout(const Duration(seconds: 15)),
        'POST' =>
          await _client
              .post(
                uri,
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 15)),
        'PUT' =>
          await _client
              .put(
                uri,
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 15)),
        'DELETE' =>
          await _client.delete(uri).timeout(const Duration(seconds: 15)),
        _ => throw ArgumentError.value(method, 'method'),
      };
      return _decodeResponse(response);
    } on SocketException {
      throw const ApiException(
        'Impossible de joindre l’API. Vérifiez son adresse et sa disponibilité.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Le serveur met trop de temps à répondre. Réessayez plus tard.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre l’API. Vérifiez votre connexion et la configuration CORS.',
      );
    }
  }

  Future<dynamic> _requestMultipart(
    String path,
    Map<String, String> fields,
    Uint8List imageBytes,
    String imageFilename,
  ) async {
    final request = http.MultipartRequest('POST', _endpoint(path))
      ..fields.addAll(fields)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFilename,
        ),
      );
    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      return _decodeResponse(response);
    } on SocketException {
      throw const ApiException(
        'Impossible de joindre l’API. Vérifiez son adresse et sa disponibilité.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Le serveur met trop de temps à répondre. Réessayez plus tard.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre l’API. Vérifiez votre connexion et la configuration CORS.',
      );
    }
  }

  dynamic _decodeResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Erreur du serveur (${response.statusCode}).');
      }
      throw const ApiException('La réponse de l’API n’est pas un JSON valide.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _serverException(response.statusCode, decoded);
    }
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw const ApiException('La réponse de l’API est invalide.');
    }
    return decoded['data'];
  }

  ApiException _serverException(int statusCode, dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      final errors = decoded['errors'];
      final details = errors is Map
          ? errors.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join('; ')
          : '';
      if (message is String && details.isNotEmpty) {
        return ApiException('$message ($details)');
      }
      if (message is String && message.isNotEmpty) {
        return ApiException(message);
      }
    }
    return ApiException('Erreur du serveur ($statusCode).');
  }

  void close() => _client.close();
}
