import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoorTheme {
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color backgroundChalk = Color(0xFFF8F5F0);
  static const Color surfaceDark = Color(0xFF0B1326);
  static const Color onSurfaceLight = Color(0xFFDAE2FD);

  // Dark mode surface variants
  static const Color _darkCard = Color(0xFF152038);
  static const Color _darkCardAlt = Color(0xFF1A2744);
  static const Color _darkInputBg = Color(0xFF1E2D4D);

  // ─── Context-aware color helpers ─────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Primary text/icon color — navy in light, cream in dark
  static Color textColor(BuildContext context) =>
      isDark(context) ? onSurfaceLight : primaryNavy;

  /// Secondary/muted text color
  static Color textMuted(BuildContext context) =>
      isDark(context)
          ? onSurfaceLight.withValues(alpha: 0.6)
          : primaryNavy.withValues(alpha: 0.6);

  /// Scaffold background
  static Color background(BuildContext context) =>
      isDark(context) ? surfaceDark : backgroundChalk;

  /// Card / container on top of scaffold (white in light, dark card in dark)
  static Color cardColor(BuildContext context) =>
      isDark(context) ? _darkCard : Colors.white;

  /// Alternate card / muted container (e.g. Color(0xFFF6F3EE) in light)
  static Color cardAlt(BuildContext context) =>
      isDark(context) ? _darkCardAlt : const Color(0xFFF6F3EE);

  /// Input field background
  static Color inputBg(BuildContext context) =>
      isDark(context) ? _darkInputBg : const Color(0xFFF0EDE9);

  /// Icon background / badge background
  static Color iconBg(BuildContext context) =>
      isDark(context) ? _darkCardAlt : const Color(0xFFEBE8E3);

  /// Divider / border color
  static Color border(BuildContext context) =>
      isDark(context)
          ? onSurfaceLight.withValues(alpha: 0.1)
          : primaryNavy.withValues(alpha: 0.1);

  /// AppBar background
  static Color appBarBg(BuildContext context) =>
      isDark(context) ? surfaceDark : Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundChalk,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: accentGold,
        surface: backgroundChalk,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.64,
          color: primaryNavy,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryNavy,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          color: primaryNavy.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: primaryNavy,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundChalk,
        elevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          color: primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryNavy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F3EE),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC6C6CD)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC6C6CD)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryNavy, width: 2),
        ),
        labelStyle: GoogleFonts.manrope(
          color: primaryNavy.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: onSurfaceLight,
        secondary: accentGold,
        surface: surfaceDark,
        onSurface: onSurfaceLight,
        onPrimary: surfaceDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.64,
          color: onSurfaceLight,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          color: onSurfaceLight.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: accentGold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          color: onSurfaceLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: onSurfaceLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: onSurfaceLight,
          foregroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputBg,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: onSurfaceLight.withValues(alpha: 0.2)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: onSurfaceLight.withValues(alpha: 0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: accentGold, width: 2),
        ),
        labelStyle: GoogleFonts.manrope(
          color: onSurfaceLight.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
