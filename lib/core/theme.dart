import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandPrimary = Color(0xFF007AFF); // A vibrant blue for main actions and branding
  static const Color brandAccent = Color(0xFFFF9500); // A lively orange for secondary actions and highlights (like the call button)

  // Light Theme Colors
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: brandPrimary,
    colorScheme: ColorScheme.light(
      primary: brandPrimary,
      secondary: brandAccent,
      surface: Colors.white, // Card and background for white elements
      background: const Color(0xFFF2F2F7), // Light grey background for the scaffold
      onPrimary: Colors.white, // Text/icon color on primary background
      onSecondary: Colors.white, // Text/icon color on secondary background
      onSurface: Colors.black87, // Text/icon color on surface (cards)
      onBackground: Colors.black87, // Text/icon color on scaffold background
      error: Colors.redAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7), // Very light grey
    cardColor: Colors.white, // White for cards and bottom nav
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // App bar text color
      elevation: 0.5, // Subtle shadow for app bar
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: brandAccent, // Default FAB uses accent
      foregroundColor: Colors.white,
      elevation: 6.0, // Match the new FAB elevation
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandPrimary,
        side: BorderSide(color: brandPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: brandPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      labelStyle: TextStyle(color: Colors.grey.shade700), // Label text color
      prefixIconColor: Colors.grey.shade600, // Prefix icon color
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: Colors.grey.shade300,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black87, fontSize: 22),
      titleMedium: TextStyle(color: Colors.black87, fontSize: 16),
      titleSmall: TextStyle(color: Colors.black54, fontSize: 14),
      headlineSmall: TextStyle(color: Colors.black87, fontSize: 24),
      headlineMedium: TextStyle(color: Colors.black87, fontSize: 28),
      labelLarge: TextStyle(color: Colors.white),
    ),
  );

  // Dark Theme Colors
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: brandPrimary,
    colorScheme: ColorScheme.dark(
      primary: brandPrimary,
      secondary: brandAccent,
      surface: const Color(0xFF1C1C1E), // Dark card/surface color
      background: const Color(0xFF000000), // Pure black background
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      onBackground: Colors.white70,
      error: Colors.redAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000), // Pure black
    cardColor: const Color(0xFF1C1C1E), // Dark grey for cards and bottom nav
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white, // App bar text color
      elevation: 0.5,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: brandAccent,
      foregroundColor: Colors.white,
      elevation: 6.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandPrimary,
        side: BorderSide(color: brandPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: brandPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      labelStyle: TextStyle(color: Colors.grey.shade300),
      prefixIconColor: Colors.grey.shade400,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: Colors.grey.shade800,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontSize: 22),
      titleMedium: TextStyle(color: Colors.white, fontSize: 16),
      titleSmall: TextStyle(color: Colors.grey, fontSize: 14),
      headlineSmall: TextStyle(color: Colors.white, fontSize: 24),
      headlineMedium: TextStyle(color: Colors.white, fontSize: 28),
      labelLarge: TextStyle(color: Colors.white),
    ),
  );
}