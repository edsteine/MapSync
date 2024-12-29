// lib/core/config/routes.dart
import 'package:flutter/material.dart';
import 'package:mobile/features/map/map_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';

// ignore: avoid_classes_with_only_static_members
class AppRoutes {
  static const String map = '/map';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    map: (context) => const MapScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
