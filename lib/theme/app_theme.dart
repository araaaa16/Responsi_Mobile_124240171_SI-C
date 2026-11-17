import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBackground = Color(0xFFF7F8F6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF202521);
  static const Color secondaryText = Color(0xFF858B85);
  static const Color primaryAccent = Color(0xFF97CE4C);
  static const Color softAccent = Color(0xFFEAF4DE);
  static const Color border = Color(0xFFE9ECE7);

  static const Color aliveStatus = Color(0xFF70B85A);
  static const Color deadStatus = Color(0xFFE46D6D);
  static const Color unknownStatus = Color(0xFFA0A5AD);

  static const Color portalGreen = primaryAccent;
  static const Color portalGreenDark = Color(0xFF7CB33E);
  static const Color darkNavy = primaryText;
  static const Color cardColor = cardBackground;
  static const Color cardColorLight = border;
  static const Color surfaceBorder = border;
  static const Color deepSpaceNavy = primaryBackground;
  static const Color darkSurface = cardBackground;
  static const Color surfaceElevated = cardBackground;
  static const Color white = cardBackground;
  static const Color offWhite = cardBackground;
  static const Color mutedGray = secondaryText;
  static const Color dangerRed = deadStatus;
  static const Color deadColor = deadStatus;
  static const Color aliveColor = aliveStatus;
  static const Color unknownColor = unknownStatus;

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return aliveStatus;
      case 'dead':
        return deadStatus;
      default:
        return unknownStatus;
    }
  }

  static ThemeData get lightTheme {
    return newMethod();
  }

  static ThemeData newMethod() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        secondary: softAccent,
        surface: cardBackground,
        error: deadStatus,
        onSurface: primaryText,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
          color: secondaryText,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: secondaryText),
        bodySmall: TextStyle(color: secondaryText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: primaryText),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deadStatus, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deadStatus, width: 1.5),
        ),
        labelStyle: const TextStyle(color: secondaryText, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFFADB3AB), fontSize: 14),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryText,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerColor: border,
      useMaterial3: true,
    );
  }
  static ThemeData get darkTheme => lightTheme;
}
