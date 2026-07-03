import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Voyage - Theme
/// Thème clair + sombre, Material 3, typographie Nunito (Google Fonts).
class AppTheme {
  // Couleurs de marque
  static const Color primaryColor = Color(0xFF2D5A5A); // Teal foncé
  static const Color secondaryColor = Color(0xFFE8B86D); // Or/Ambre
  static const Color errorColor = Color(0xFFB00020);

  // Couleurs de texte (thème clair — préférer les helpers *Of(context)
  // dans les widgets pour supporter le mode sombre)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnPrimary = Colors.white;

  /// Couleur de texte secondaire adaptée au thème courant.
  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFB3B3B3)
          : textSecondary;

  /// Couleur de surface pour les cartes/panneaux custom.
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Fond doux pour les encadrés (script audio, sheets...).
  static Color softBackgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFF7F7F7);

  /// Bordure discrète adaptée au thème.
  static Color subtleBorderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFE0E0E0);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: isDark ? const Color(0xFF7FBFBF) : primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121414) : const Color(0xFFF5F5F5),
    );

    final textColor = isDark ? const Color(0xFFEDEDED) : textPrimary;
    final textColorSecondary =
        isDark ? const Color(0xFFB3B3B3) : textSecondary;

    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.nunito(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, color: textColorSecondary),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1C2222) : primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textOnPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 1 : 2,
        color: isDark ? const Color(0xFF1E2424) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: isDark ? const Color(0xFF10302F) : textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
