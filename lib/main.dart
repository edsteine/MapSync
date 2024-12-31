///
/// File: lib/main.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Entry point of the Flutter application. Initializes services and sets up the app.
/// Updates: Initial setup with theme management, Mapbox access, and notification permissions.
/// Used Libraries: flutter/material.dart, flutter_dotenv/flutter_dotenv.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart
///
library;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/config/app_routes.dart';
import 'package:mobile/core/config/app_theme.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/utils/app_constants.dart';

void main() async {
  // Ensures that Flutter is initialized before running any app-specific code.
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file, allowing for configuration.
  await dotenv.load();
  // Sets the Mapbox access token using the configuration from the loaded .env file.
  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  // Initializes the notification service for managing push notifications.
  await NotificationService.init();
  // Requests permission to send notifications to the user.
  await PermissionService.requestNotificationPermissions();
  // Entry point for the app, wraps the main app with ProviderScope for riverpod.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
// Global key for navigation, to be used outside of the widget tree.
final navigatorKey = GlobalKey<NavigatorState>();

/// `MyApp` is the root widget of the application, utilizing `ConsumerWidget` to access the Riverpod state.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the themeModeProvider to dynamically update the theme based on the selected mode.
    final themeMode = ref.watch(themeModeProvider);
    // Material App is the basic app with configurations like navigator, theme, and routes.
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Offline Maps',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

///  Provides the current theme mode, initialized from storage, this provider can be watched for updates.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Fetches the storage provider to load stored data from local storage.
  final storageAsync = ref.watch(storageProvider);
  //Handles asynchronous loading of storage data to determine the stored theme mode
  final storage = storageAsync.when(
    data: (data) => data,
    error: (error, stack) {
      // Prints an error message to the console if the theme cannot be loaded from storage
      debugPrint('Error loading theme from storage: $error');
      return null;
    },
    loading: () => null,
  );
  // If the storage service is null, uses light theme by default.
  if (storage == null) {
    return ThemeMode.light;
  }
  // Gets the theme mode stored in storage.
  final themeString = storage.getString(AppConstants.themeModeKey);
  // Returns the theme based on the stored value or default light theme.
  return themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
});