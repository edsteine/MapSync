// lib/core/config/theme.dart
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static const Color primaryColor = Color(0xff6200ee);
  static const Color secondaryColor = Color(0xff03dac6);
  static const Color errorColor = Color(0xffb00020);

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