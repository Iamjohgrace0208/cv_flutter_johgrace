import 'package:material_ui/material_ui.dart';

import '../../data/api_service.dart';
import '../contact/contact_page.dart';
import '../family/family_page.dart';
import '../home/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.apiService,
    required this.onToggleTheme,
    required this.onLogout,
    super.key,
  });

  final ApiService apiService;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = ['Portfolio', 'Ma famille', 'Contact'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final pages = <Widget>[
      HomePage(
        onNavigateTo: _selectPage,
        onToggleTheme: widget.onToggleTheme,
        onLogout: widget.onLogout,
      ),
      FamilyPage(apiService: widget.apiService),
      const ContactPage(),
    ];

    return PopScope<void>(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) _selectPage(0);
      },
      child: Scaffold(
        appBar: _selectedIndex == 0
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  tooltip: 'Retour au portfolio',
                  onPressed: () => _selectPage(0),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: Text(_titles[_selectedIndex]),
                actions: [
                  if (isWide)
                    for (var index = 0; index < _titles.length; index++)
                      TextButton(
                        onPressed: () => _selectPage(index),
                        child: Text(_titles[index].toUpperCase()),
                      ),
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
                  IconButton(
                    tooltip: 'Se déconnecter',
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: _selectedIndex == 0 || isWide
            ? null
            : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectPage,
                destinations: _barDestinations,
              ),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
  }

  static const _barDestinations = [
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'Portfolio',
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
  ];
}
