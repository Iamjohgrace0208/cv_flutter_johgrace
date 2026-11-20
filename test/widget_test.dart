import 'package:cv_flutter_johgrace/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login validates, toggles theme, and opens the portfolio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CvFlutterApp());

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

    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Veuillez saisir votre identifiant.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'demo');
    await tester.enterText(find.byType(TextFormField).last, 'demo');
    await tester.pump();

    await tester.ensureVisible(find.byTooltip('Activer le thème sombre'));
    await tester.tap(find.byTooltip('Activer le thème sombre'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('PORTFOLIO PERSONNEL'), findsOneWidget);
    expect(find.text('Sadiki Selemani Joseph Grâce'), findsOneWidget);
    expect(find.text('INFORMATICIEN | PASTEUR'), findsOneWidget);

    await tester.tap(find.byTooltip('Activer le thème clair'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('family cards open a navigable photo gallery', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CvFlutterApp());
    await tester.enterText(find.byType(TextFormField).first, 'demo');
    await tester.enterText(find.byType(TextFormField).last, 'demo');
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ma famille').last);
    await tester.pumpAndSettle();
    expect(find.text('Matakio Annonciate'), findsOneWidget);
    expect(find.text('Nabintu Fesa Deborah'), findsOneWidget);
    expect(find.text('Père'), findsNothing);

    final galleryButton = find.text('3 photos').first;
    await tester.ensureVisible(galleryButton);
    await tester.tap(galleryButton);
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact').last);
    await tester.pumpAndSettle();
    expect(find.text('Me joindre'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('TikTok'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('TikTok'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('YouTube'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('YouTube'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('WhatsApp'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('WhatsApp'), findsOneWidget);
  });
}
