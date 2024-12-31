///
/// File: lib/core/config/app_config.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Configuration settings for the application, such as API endpoints and map settings.
/// Updates: Initial configuration, added defaults for access token and API base URL.
/// Used Libraries: flutter_dotenv/flutter_dotenv.dart, flutter_riverpod/flutter_riverpod.dart
///
library;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AppConfig class provides static properties for application configuration
// ignore: avoid_classes_with_only_static_members
class AppConfig {
    /// Retrieves the Mapbox access token from environment variables or defaults.
  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
      'pk.eyJ1IjoiZWRzdGVpbmUiLCJhIjoiY201OGMzZWFxMXBpMTJuczJvY2s1Y2pvYiJ9.9fFMjW1mum1H9WqA2E1rQg';
  ///  Base URL for the API communication with the backend
  static const String apiBaseUrl =
      'https://w-project-u75x.onrender.com/api/v1/';
  ///  Application version number
  static const String appVersion = '1.0.0';

  /// Minimum height for image compression for the images to download for offline usage.
  static const int compressImageMinHeight = 1920;
  /// Minimum width for image compression for the images to download for offline usage.
  static const int compressImageMinWidth = 1080;
  /// Quality for the image compression, between 0 and 100 for images to download for offline usage.
  static const int compressImageQuality = 85;

  // User Paths: These are API paths related to user operations.
    /// User base path for user operations
  static String get userPath => '${apiBaseUrl}users/';
    /// User path for verification
  static String get userVerify => '${userPath}verify/';
    /// User path for forgot password
  static String get userForgotPassword => '${userPath}forgot_password/';
     /// User path for reset password
  static String get userResetPassword => '${userPath}reset_password/';

  // Locations Paths: These are API paths related to location operations.
    /// Location base path for locations
  static String get locationsPath =>
      '${apiBaseUrl}locations/?page=1&page_size=150';
  /// Location path for nearby locations
  static String get locationsNearbyPath => '${apiBaseUrl}nearby/';
  /// Location path for statistics
  static String get locationsStatistics => '${apiBaseUrl}statistics/';

  /// Default map settings for initial map view.
  static Map<String, double> defaultMapSettings = {
    'initialLatitude': 0.0,
    'initialLongitude': 0.0,
    'initialZoom': 2.0,
    'minZoom': 0.0,
    'maxZoom': 22.0,
  };

   /// Default settings for offline map downloads
  static Map<String, int> offlineMapSettings = {
    'maxTiles': 10000,
    'minZoom': 10,
    'maxZoom': 15,
  };
}

/// ConfigProvider to provide the AppConfig as a provider instance.
final configProvider = Provider<AppConfig>((ref) => AppConfig());