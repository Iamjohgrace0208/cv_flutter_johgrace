import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const ink = Color(0xFF142238);
  static const forest = Color(0xFF182A43);
  static const leaf = Color(0xFF9A8352);
  static const cream = Color(0xFFF5F2EA);
  static const paper = Color(0xFFFFFEFB);
  static const terracotta = Color(0xFFAA8A51);
  static const muted = Color(0xFF747B83);
  static const line = Color(0xFFE7E2D8);
}

extension AppThemeColors on BuildContext {
  Color get appInk => Theme.of(this).colorScheme.onSurface;
  Color get appForest => Theme.of(this).colorScheme.primary;
  Color get appLeaf => Theme.of(this).colorScheme.secondary;
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
          primaryContainer: const Color(0xFFE9E5DC),
          onPrimaryContainer: AppColors.ink,
          secondaryContainer: const Color(0xFFF1EADB),
          onSecondaryContainer: AppColors.ink,
        );

    return _createTheme(scheme, scaffoldBackground: AppColors.cream);
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD7B66D),
      onPrimary: Color(0xFF17130B),
      secondary: Color(0xFFE2C988),
      onSecondary: Color(0xFF211A0D),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF151515),
      onSurface: Color(0xFFF3F0E8),
      onSurfaceVariant: Color(0xFFB7B2A8),
      outline: Color(0xFF827A69),
      outlineVariant: Color(0xFF36332D),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFECE8DF),
      onInverseSurface: Color(0xFF252A30),
      inversePrimary: Color(0xFF67552F),
      surfaceTint: Color(0xFFD7B66D),
    );

    return _createTheme(scheme, scaffoldBackground: const Color(0xFF090909));
  }

  static ThemeData _createTheme(
    ColorScheme scheme, {
    required Color scaffoldBackground,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      visualDensity: VisualDensity.standard,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: scheme.onSurface,
          fontSize: 38,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineMedium: TextStyle(
          color: scheme.onSurface,
          fontSize: 27,
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
          height: 1.65,
        ),
        bodyMedium: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 13,
          height: 1.55,
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
        prefixIconColor: scheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.secondary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
