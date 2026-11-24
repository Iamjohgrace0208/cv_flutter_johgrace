import 'package:cv_flutter_johgrace/core/app_theme.dart';
import 'package:cv_flutter_johgrace/pages/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('presents the portfolio sections and current ISIG-GOMA studies', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: HomePage(
            onNavigateTo: (_) {},
            onToggleTheme: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final section in [
      'WHO I AM',
      'TECHNOLOGY',
      'EDUCATION',
      'CERTIFICATIONS & DISTINCTIONS',
      'MINISTRY',
      'CREATION',
      'MY WORLD',
      'CONTACT',
    ]) {
      expect(find.text(section), findsOneWidget);
    }
    expect(
      find.text(
        'Institut Supérieur d’Informatique et de Gestion de Goma (ISIG-GOMA)',
      ),
      findsOneWidget,
    );
    expect(find.text('Licence en Sciences informatiques'), findsOneWidget);
    expect(find.text('Formation en cours'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de l’ISIG-GOMA'), findsOneWidget);
    expect(find.text('Document 01'), findsOneWidget);
    expect(find.text('Document 04'), findsOneWidget);

    for (final sermon in [
      "L'URGENCE DE LA PRIÈRE - JOSEPH SELEMANI",
      'DIEU EST LÀ, MAIS…',
      'SANCTIFIÉS POUR PARAÎTRE…',
      'MON JÉRUSALEM…',
      'TON MIRACLE EST EXIGEANT',
      "LA VICTOIRE PAR LES ARMES DE DIEU : L'ARME APPROPRIÉE",
      "L'HEURE VIENT",
      'QUAND TOUT BOUGE, ACCROCHE-TOI À CE QUE DIEU A DIT',
    ]) {
      expect(find.text(sermon), findsOneWidget);
    }

    final sermonCards = find.byTooltip('Ouvrir sur YouTube');
    expect(sermonCards, findsNWidgets(8));
    final sermonImages = tester
        .widgetList<Image>(
          find.descendant(of: sermonCards, matching: find.byType(Image)),
        )
        .map((image) => (image.image as AssetImage).assetName)
        .toList();
    expect(sermonImages, hasLength(8));
    expect(sermonImages.toSet(), hasLength(8));
    expect(
      sermonImages.every((path) => path.startsWith('assets/images/johgrace/')),
      isTrue,
    );
  });

  testWidgets('lays out the portfolio without overflow at narrow widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in [
      const Size(360, 800),
      const Size(768, 900),
      const Size(1440, 1000),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: HomePage(
              onNavigateTo: (_) {},
              onToggleTheme: () {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'Viewport $size');
    }
  });

  testWidgets('opens a certificate in a zoomable full-size viewer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: HomePage(
            onNavigateTo: (_) {},
            onToggleTheme: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final certificate = find.byTooltip('Ouvrir Document 01');
    await tester.ensureVisible(certificate);
    await tester.tap(certificate);
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Document 01'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Fermer le document'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
