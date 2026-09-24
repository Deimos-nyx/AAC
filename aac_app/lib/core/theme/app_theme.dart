import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the app's [ThemeData]. Kept intentionally simple: the AAC board
/// itself does its own per-category coloring, so the global theme mostly
/// governs chrome (app bars, buttons, dialogs) in settings/caregiver screens.
class AppTheme {
  AppTheme._();

  static ThemeData standard() => _base(
    primary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.surface,
    border: AppColors.border,
    text: AppColors.textPrimary,
  );

  /// High-contrast variant: pure black background, white text/borders, and a
  /// single saturated accent. Used when the accessibility setting is on.
  static ThemeData highContrast() => _base(
    primary: AppColors.hcPrimary,
    background: AppColors.hcBackground,
    surface: AppColors.hcSurface,
    border: AppColors.hcBorder,
    text: AppColors.hcText,
    isDark: true,
  );

  static ThemeData _base({
    required Color primary,
    required Color background,
    required Color surface,
    required Color border,
    required Color text,
    bool isDark = false,
  }) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: AppColors.secondary,
        surface: surface,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          side: BorderSide(color: border),
          foregroundColor: text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
      ),
      // Accessibility setting "reduced animation" is enforced at the
      // navigation layer (see app_router.dart) rather than here, since page
      // transitions are controlled per-route.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
