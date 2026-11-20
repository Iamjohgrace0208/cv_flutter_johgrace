import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const ink = Color(0xFF202C27);
  static const forest = Color(0xFF285A49);
  static const leaf = Color(0xFF73977A);
  static const cream = Color(0xFFF7F5EF);
  static const paper = Color(0xFFFFFEFB);
  static const terracotta = Color(0xFFC7795C);
  static const muted = Color(0xFF7F8982);
  static const line = Color(0xFFE7E6DE);
}

extension AppThemeColors on BuildContext {
  Color get appInk => Theme.of(this).colorScheme.onSurface;
  Color get appForest => Theme.of(this).colorScheme.primary;
  Color get appLeaf => Theme.of(this).colorScheme.primary;
  Color get appCream => Theme.of(this).scaffoldBackgroundColor;
  Color get appPaper => Theme.of(this).colorScheme.surface;
  Color get appTerracotta => Theme.of(this).colorScheme.secondary;
  Color get appMuted => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get appLine => Theme.of(this).colorScheme.outlineVariant;
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.forest,
          primary: AppColors.forest,
          secondary: AppColors.terracotta,
          surface: AppColors.paper,
        ).copyWith(
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.muted,
          outlineVariant: AppColors.line,
        );

    return _createTheme(scheme, scaffoldBackground: AppColors.cream);
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9BC8AA),
      onPrimary: Color(0xFF173224),
      secondary: Color(0xFFE4A089),
      onSecondary: Color(0xFF402017),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF1D2822),
      onSurface: Color(0xFFEDF4EE),
      onSurfaceVariant: Color(0xFFB8C6BB),
      outline: Color(0xFF84958A),
      outlineVariant: Color(0xFF3D4E43),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFEDF4EE),
      onInverseSurface: Color(0xFF26312A),
      inversePrimary: Color(0xFF426B53),
      surfaceTint: Color(0xFF9BC8AA),
    );

    return _createTheme(scheme, scaffoldBackground: const Color(0xFF121A15));
  }

  static ThemeData _createTheme(
    ColorScheme scheme, {
    required Color scaffoldBackground,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: scheme.onSurface,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          color: scheme.onSurface,
          fontSize: 25,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: scheme.onSurface,
          fontSize: 15,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 17,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
    );
  }
}
