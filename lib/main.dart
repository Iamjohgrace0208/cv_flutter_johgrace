import 'package:material_ui/material_ui.dart';

import 'data/api_service.dart';
import 'core/app_theme.dart';
import 'pages/login/login_page.dart';

void main() {
  runApp(const CvFlutterApp());
}

class CvFlutterApp extends StatefulWidget {
  const CvFlutterApp({this.apiService, super.key});

  final ApiService? apiService;

  @override
  State<CvFlutterApp> createState() => _CvFlutterAppState();
}

class _CvFlutterAppState extends State<CvFlutterApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Johgrace · Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 280),
      themeAnimationCurve: Curves.easeInOut,
      home: LoginPage(
        apiService: widget.apiService,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
