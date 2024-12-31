///
/// File: lib/core/config/app_config.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Configuration settings for the application, such as API endpoints and map settings.
/// Updates: Initial configuration, added defaults for access token and API base URL.
/// Used Libraries: flutter_dotenv/flutter_dotenv.dart, flutter_riverpod/flutter_riverpod.dart
///
library;

import 'package:flutter/material.dart';
import 'package:mobile/features/map/map_screen.dart';
import 'package:mobile/features/offline_map/offline_map_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';
import 'package:mobile/features/splash/splash_screen.dart';

//  AppRoutes class provides static properties for managing navigation routes within the app.
// ignore: avoid_classes_with_only_static_members
class AppRoutes {
  static const String splash = '/';
    /// Route for the map screen.
  static const String map = '/map';
     /// Route for the settings screen.
  static const String settings = '/settings';
    /// Route for the offline map screen.
  static const String offlineMap = '/offline_map';

    /// Defines the routes, linking route names to their corresponding screen widgets.
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    map: (context) => const MapScreen(),
    settings: (context) => const SettingsScreen(),
    offlineMap: (context) => const OfflineMapScreen(),
  };
}