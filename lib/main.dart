// lib/main.dart
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
import 'package:mobile/core/utils/context_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // PerformanceMonitor.startMonitoring();
  await dotenv.load();
  //  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  await NotificationService.init();
  await PermissionService.requestNotificationPermissions();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(contextProvider.notifier, (previous, next) {
      ref.read(contextProvider.notifier).update((state) => context);
    });

    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
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
  final storageAsync = ref.watch(storageProvider);
  final storage = storageAsync.when(
    data: (data) => data,
    error: (error, stack) {
      debugPrint('Error loading theme from storage: $error');
      return null;
    },
    loading: () => null,
  );
  if (storage == null) {
    return ThemeMode.light;
  }
  final themeString =  storage.getString(AppConstants.themeModeKey);
  // ignore: unrelated_type_equality_checks
  return themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
});