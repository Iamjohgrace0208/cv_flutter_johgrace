import 'package:material_ui/material_ui.dart';

import '../contact/contact_page.dart';
import '../family/family_page.dart';
import '../home/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = ['Mon parcours', 'Ma famille', 'Contact'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pages = <Widget>[
      HomePage(onNavigateTo: _selectPage),
      const FamilyPage(),
      const ContactPage(),
    ];

    return PopScope<void>(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          _selectPage(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          actions: [
            IconButton(
              tooltip: isDarkMode
                  ? 'Activer le thème clair'
                  : 'Activer le thème sombre',
              onPressed: widget.onToggleTheme,
              icon: Icon(
                isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Mon parcours',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Ma famille',
            ),
            NavigationDestination(
              icon: Icon(Icons.alternate_email_rounded),
              selectedIcon: Icon(Icons.alternate_email_rounded),
              label: 'Contact',
            ),
          ],
        ),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
  }
}
