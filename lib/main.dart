// lib/main.dart
import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  await NotificationService.init();
  await PermissionService.requestNotificationPermissions();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Offline Maps',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.map,
      routes: AppRoutes.routes,
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Initialize from storage
  final storageAsync = ref.watch(storageProvider2);
  final storage = storageAsync.when(
    data: (data) => data,
    error: (error, stack) => null,
    loading: () => null,
  );
  if (storage == null) {
    return ThemeMode.light;
  }
  final themeString = storage.getString(AppConstants.themeModeKey);
  return themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
});
