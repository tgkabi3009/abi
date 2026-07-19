import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 theme untuk aplikasi.
/// Warna utama: hijau brand (#009966) — sama dengan web admin V.7.
class AppTheme {
  AppTheme._();

  static const Color _brandGreen = Color(0xFF009966);
  static const Color _brandGreenDark = Color(0xFF007A4F);
  static const Color _brandTeal = Color(0xFF06B6D4);

  static const Color _brandLight = Color(0xFFE6F4EE);
  static const Color _surfaceLight = Color(0xFFFAFBFA);
  static const Color _surfaceDark = Color(0xFF0F1311);

  static const Color _errorRed = Color(0xFFDC2626);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _infoBlue = Color(0xFF3B82F6);
  static const Color _neutralGray = Color(0xFF6B7280);

  /// Light theme.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
      primary: _brandGreen,
      onPrimary: Colors.white,
      secondary: _brandTeal,
      onSecondary: Colors.white,
      surface: _surfaceLight,
      onSurface: Color(0xFF1A1F1B),
      error: _errorRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: Color(0xFF1A1F1B),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1F1B),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _brandGreen,
          side: BorderSide(color: _brandGreen),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _brandGreen,
        unselectedItemColor: _neutralGray,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // === Brand colors exposed for widgets ===
  static const Color brand = _brandGreen;
  static const Color brandDark = _brandGreenDark;
  static const Color teal = _brandTeal;
  static const Color brandLight = _brandLight;
  static const Color error = _errorRed;
  static const Color warning = _warningAmber;
  static const Color info = _infoBlue;
  static const Color neutral = _neutralGray;

  /// Warna status absensi (sama dengan web admin V.7).
  static Color statusColor(String status) {
    switch (status) {
      case 'hadir':
        return _brandGreen;
      case 'diganti':
        return _warningAmber;
      case 'izin':
        return _infoBlue;
      case 'alpa':
        return _errorRed;
      case 'pengganti':
        return Color(0xFF8B5CF6);
      case 'belum':
      default:
        return _neutralGray;
    }
  }

  /// Warna prioritas notifikasi.
  static Color priorityColor(String prioritas) {
    switch (prioritas) {
      case 'tinggi':
        return _errorRed;
      case 'sedang':
        return _warningAmber;
      case 'rendah':
      default:
        return _neutralGray;
    }
  }
}
