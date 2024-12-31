import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: avoid_classes_with_only_static_members
class AppConfig {
  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
      'pk.eyJ1IjoiZWRzdGVpbmUiLCJhIjoiY201OGMzZWFxMXBpMTJuczJvY2s1Y2pvYiJ9.9fFMjW1mum1H9WqA2E1rQg';
  static const String apiBaseUrl =
      'https://w-project-u75x.onrender.com/api/v1/';
  static const String appVersion = '1.0.0';

  static const int compressImageMinHeight = 1920;
  static const int compressImageMinWidth = 1080;
  static const int compressImageQuality = 85;

  // User Paths
  static String get userPath => '${apiBaseUrl}users/';
  static String get userVerify => '${userPath}verify/';
  static String get userForgotPassword => '${userPath}forgot_password/';
  static String get userResetPassword => '${userPath}reset_password/';

  // Locations Paths
  static String get locationsPath =>
      '${apiBaseUrl}locations/?page=1&page_size=150';
  static String get locationsNearbyPath => '${apiBaseUrl}nearby/';
  static String get locationsStatistics => '${apiBaseUrl}statistics/';

  static Map<String, double> defaultMapSettings = {
    'initialLatitude': 0.0,
    'initialLongitude': 0.0,
    'initialZoom': 2.0,
    'minZoom': 0.0,
    'maxZoom': 22.0,
  };

  static Map<String, int> offlineMapSettings = {
    'maxTiles': 10000,
    'minZoom': 10,
    'maxZoom': 15,
  };
}

final configProvider = Provider<AppConfig>((ref) => AppConfig());
