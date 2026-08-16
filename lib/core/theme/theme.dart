import 'package:flutter/material.dart';

class AppTheme {
  // exact hex colors derived from UI screenshots
  static const Color darkBg = Color(0xFF090B0F); // Very dark screen background
  static const Color darkSurface = Color(0xFF131722); // Mid dark surface (inputs, list items)
  static const Color darkCard = Color(0xFF1B202D); // Lighter dark card background
  
  static const Color primaryNeon = Color(0xFF00E5C9); // Active cyan/teal accent
  static const Color secondaryGold = Color(0xFFFFA500); // Orange/Gold for tests
  static const Color accentTeal = Color(0xFF00BFFF); // Bright blue/teal
  static const Color errorRed = Color(0xFFFF453A); // Red warning color
  
  static const Color textPrimary = Color(0xFFFFFFFF); // Clean white text
  static const Color textSecondary = Color(0xFF8E9AA8); // Muted slate text
  static const Color borderMuted = Color(0xFF222634); // Thin card borders

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryGold,
        tertiary: accentTeal,
        surface: darkSurface,
        error: errorRed,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderMuted, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryNeon),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Solid white background (like the 'Save' button in Screen 2)
          foregroundColor: Colors.black, // Black text
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill button shape
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white, // Outlined white (like the 'Pause' button in Screen 3)
          side: const BorderSide(color: Color(0xFF3A4257), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill shape
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNeon,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Highly rounded like the Screen 1 inputs
          borderSide: const BorderSide(color: borderMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: borderMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryNeon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: errorRed),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderMuted,
        thickness: 1,
      ),
    );
  }
}
