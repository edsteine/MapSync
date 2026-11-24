///
/// File: lib/core/config/app_theme.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Defines the theme settings for the Flutter application.
/// Updates: Initial setup of light and dark themes with primary, secondary, and error colors.
/// Used Libraries: flutter/material.dart
///
library;
import 'package:flutter/material.dart';

// AppTheme class provides static properties for application's theme configurations
// ignore: avoid_classes_with_only_static_members
class AppTheme {
  /// Primary color for the theme
  static const Color primaryColor = Color(0xff6200ee);
  /// Secondary color for the theme
  static const Color secondaryColor = Color(0xff03dac6);
  /// Error color for the theme
  static const Color errorColor = Color(0xffb00020);

  /// Light theme settings for the app
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
      onPrimary: Colors.white,
      surface: Colors.grey[100],
      onSurface: Colors.black,
      primaryContainer: primaryColor,
      onPrimaryContainer: Colors.white,
      secondaryContainer: secondaryColor,
      onSecondaryContainer: Colors.black,
      error: errorColor,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor, // This will color the app bar
      foregroundColor: Colors.white, // This will color the title and icons
    ),
    useMaterial3: true,
  );

    /// Dark theme settings for the app
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
      brightness: Brightness.dark,
      onPrimary: Colors.black,
      surface: Colors.grey[900],
      onSurface: Colors.white,
      primaryContainer: primaryColor,
      onPrimaryContainer: Colors.white,
      secondaryContainer: secondaryColor,
      onSecondaryContainer: Colors.black,
      error: errorColor,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor, // This will color the app bar
      foregroundColor: Colors.white, // This will color the title and icons
    ),
    useMaterial3: true,
  );
}