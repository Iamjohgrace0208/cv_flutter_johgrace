import 'dart:convert';

import 'package:cv_flutter_johgrace/data/api_service.dart';
import 'package:cv_flutter_johgrace/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('authenticates against the API and manages family members', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final members = <Map<String, dynamic>>[
      {
        'id': 1,
        'nom': 'Matakio',
        'postnom': 'Annonciate',
        'prenom': 'Maman',
        'lieu_naissance': 'Goma',
        'date_naissance': '1975-02-14',
        'parente': 'Mère',
        'image_url': null,
      },
    ];
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path.endsWith('/accounts/login')) {
        final credentials = jsonDecode(request.body) as Map<String, dynamic>;
        if (credentials['email'] != 'demo@example.com' ||
            credentials['password'] != 'secret123') {
          return _response(401, {
            'success': false,
            'message': 'Identifiants invalides',
          });
        }
        return _response(200, {
          'success': true,
          'data': {'id': 1, 'email': 'demo@example.com'},
        });
      }
      if (request.url.path.endsWith('/accounts/register')) {
        return _response(201, {
          'success': true,
          'data': {'id': 1, 'email': 'demo@example.com'},
        });
      }
      if (request.url.path.endsWith('/famille-membres')) {
        if (request.method == 'GET') {
          return _response(200, {'success': true, 'data': members});
        }
        if (request.method == 'POST') {
          members.add({
            ...jsonDecode(request.body) as Map<String, dynamic>,
            'id': members.isEmpty ? 1 : members.last['id'] + 1,
            'image_url': null,
          });
          return _response(201, {'success': true, 'data': members.last});
        }
      }
      final memberPath = RegExp(r'/famille-membres/(\d+)$')
          .firstMatch(request.url.path);
      if (memberPath != null) {
        final id = int.parse(memberPath.group(1)!);
        final index = members.indexWhere((member) => member['id'] == id);
        if (index < 0) {
          return _response(404, {'success': false, 'message': 'Introuvable'});
        }
        if (request.method == 'PUT') {
          members[index] = {
            ...members[index],
            ...jsonDecode(request.body) as Map<String, dynamic>,
          };
          return _response(200, {'success': true, 'data': members[index]});
        }
        if (request.method == 'DELETE') {
          members.removeAt(index);
          return _response(200, {'success': true, 'data': null});
        }
      }
      return _response(404, {'success': false, 'message': 'Introuvable'});
    });
    final apiService = ApiService(
      baseUri: Uri.parse('http://localhost/api-test/public'),
      client: client,
    );
    addTearDown(apiService.close);

    await tester.pumpWidget(CvFlutterApp(apiService: apiService));
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byType(TextFormField).last,
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isTrue,
    );

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez une adresse e-mail valide.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'pas-une-adresse');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez une adresse e-mail valide.'), findsOneWidget);

    await tester.tap(find.text('Pas encore de compte ? Créer un compte'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Compte créé. Connectez-vous pour continuer.'),
      findsOneWidget,
    );
    expect(calls, contains('POST /api-test/public/accounts/register'));

    await tester.enterText(
      find.byType(TextFormField).first,
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.ensureVisible(find.byTooltip('Activer le thème clair'));
    await tester.tap(find.byTooltip('Activer le thème clair'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('PORTFOLIO PERSONNEL'), findsOneWidget);
    expect(find.text('Sadiki Selemani Joseph Grâce'), findsOneWidget);

    await tester.tap(find.text('Ma famille').last);
    await tester.pumpAndSettle();
    expect(find.text('Maman Annonciate Matakio'), findsOneWidget);
    expect(find.text('Matakio Annonciate'), findsOneWidget);
    expect(find.text('Mitila Linda Harmonie'), findsNothing);
    expect(calls, contains('POST /api-test/public/accounts/login'));
    expect(calls, contains('GET /api-test/public/famille-membres'));

    final galleryButton = find.text('3 anciennes photos').first;
    await tester.ensureVisible(galleryButton);
    await tester.tap(galleryButton);
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'S' * 51);
    await tester.enterText(fields.at(1), 'Joseph');
    await tester.enterText(fields.at(2), 'Grace');
    await tester.enterText(fields.at(3), 'Goma');
    await tester.enterText(fields.at(4), '2024-02-31');
    await tester.enterText(fields.at(5), 'Frère');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Ajouter'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Maximum 50 caractères.'), findsOneWidget);
    await tester.enterText(fields.at(0), 'Selemani');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Ajouter'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Utilisez le format AAAA-MM-JJ.'), findsOneWidget);
    await tester.enterText(fields.at(4), '9999-01-01');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Ajouter'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('La date ne peut pas être dans le futur.'),
      findsOneWidget,
    );
    expect(calls, isNot(contains('POST /api-test/public/famille-membres')));
    await tester.enterText(fields.at(4), '2000-01-01');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Ajouter'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Grace Joseph Selemani'), findsOneWidget);
    expect(calls, contains('POST /api-test/public/famille-membres'));

    await tester.tap(find.text('Modifier').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Modifié');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Grace Joseph Modifié'), findsOneWidget);
    expect(calls, contains('PUT /api-test/public/famille-membres/2'));

    await tester.tap(find.text('Supprimer').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Supprimer'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Grace Joseph Modifié'), findsNothing);
    expect(calls, contains('DELETE /api-test/public/famille-membres/2'));

    await tester.tap(find.byTooltip('Activer le thème sombre'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

http.Response _response(int statusCode, Map<String, dynamic> body) {
  return http.Response(jsonEncode(body), statusCode);
}
