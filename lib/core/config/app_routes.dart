// lib/core/config/app_routes.dart
import 'package:flutter/material.dart';
import 'package:mobile/features/map/map_screen.dart';
import 'package:mobile/features/offline_map/offline_map_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';

// ignore: avoid_classes_with_only_static_members
class AppRoutes {
  static const String map = '/map';
  static const String settings = '/settings';
  static const String offlineMap = '/offline_map';

  static Map<String, WidgetBuilder> routes = {
    map: (context) => const MapScreen(),
    settings: (context) => const SettingsScreen(),
    offlineMap: (context) => const OfflineMapScreen(),
  };
}
