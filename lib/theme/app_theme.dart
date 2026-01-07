import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Main dark green color scheme
      primaryColor: const Color(0xFF2C3E50), // Dark greenish-blue
      primaryColorLight: const Color(0xFF34495E), // Lighter shade
      primaryColorDark: const Color(0xFF1A252F), // Darker shade
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF2C3E50), // Dark green
        primaryContainer: const Color(0xFF34495E), // Container color
        secondary: const Color(0xFF27AE60), // Accent green
        secondaryContainer: const Color(0xFF2ECC71), // Lighter accent
        surface: const Color(0xFFEEF1F3), // Light background
        background: const Color(0xFFECF0F1), // App background
        error: const Color(0xFFE74C3C), // Error red
        onPrimary: Colors.white, // Text on primary
        onSecondary: Colors.white, // Text on secondary
        onSurface: const Color(0xFF2C3E50), // Text on surface
        onBackground: const Color(0xFF2C3E50), // Text on background
        onError: Colors.white, // Text on error
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        color: Color(0xFF2C3E50), // Dark green app bar
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27AE60), // Green buttons
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2C3E50), // Dark green text
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF27AE60), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFFECF0F1),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C3E50),
        selectedItemColor: Color(0xFF2ECC71),
        unselectedItemColor: Color(0xFFBDC3C7),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF27AE60),
        foregroundColor: Colors.white,
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFBDC3C7),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Dark theme variations
      primaryColor: const Color(0xFF2C3E50),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF2C3E50),
        secondary: const Color(0xFF27AE60),
        surface: const Color(0xFF1A252F),
        background: const Color(0xFF1A252F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1A252F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A252F),
    );
  }
}
