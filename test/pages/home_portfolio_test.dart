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
        home: HomePage(
          onNavigateTo: (_) {},
          onToggleTheme: () {},
          onLogout: () {},
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
        home: HomePage(
          onNavigateTo: (_) {},
          onToggleTheme: () {},
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final certificate = find.byTooltip('Ouvrir Document 01');
    await tester.ensureVisible(certificate);
    await tester.tap(certificate);
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Document 01'), findsOneWidget);

    await tester.tap(find.byTooltip('Fermer le document'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
