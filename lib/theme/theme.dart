import 'package:flutter/material.dart';

class SproutTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7CA982), // Soft pastel green
        primary: const Color(0xFF5B8266),   // Deep soft green
        secondary: const Color(0xFF8E9B90), // Soft grayish green
        tertiary: const Color(0xFFE6AD90),  // Soft warm peach/orange
        surface: const Color(0xFFF7F9F5),   // Soft cream/greenish white background
        onSurface: const Color(0xFF2C3E35), // Dark green-grey for contrast
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9F5), // Soft cream
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF2C3E35),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF2C3E35),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Color(0xFF4A5D53)),
        bodyMedium: TextStyle(color: Color(0xFF4A5D53)),
      ),
    );
  }
}
