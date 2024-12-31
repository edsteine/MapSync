///
/// File: lib/core/utils/app_constants.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Defines application constants such as default map settings, storage keys, and error messages.
/// Updates: Initial setup with constants for map, channel IDs, storage keys and error messages.
/// Used Libraries: mapbox_maps_flutter/mapbox_maps_flutter.dart
///
library;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// AppConstants class provides static constants used throughout the application.
class AppConstants {
  // Map Constants
   /// Default longitude value
  static const double defaultLongitude = -7.6351861;
    /// Default latitude value
  static const double defaultLatitude = 33.5724805;

    /// Default zoom value for the map
  static const double defaultZoom = 14;
   /// Minimum zoom value for the map
  static const int minZoom = 0;
    /// Maximum zoom value for the map
  static const int maxZoom = 22;

  // Notification Channel Constants
    /// ID of the notification channel
  static const String channelId = 'channelId';
     /// Name of the notification channel
  static const String channelName = 'channelName';
    /// Description of the notification channel
  static const String channelDescription = 'channelDescription';
  // Storage Keys
   /// Storage key for markers
  static const String markersKey = 'markers';
   /// Storage key for theme mode
  static const String themeModeKey = 'theme_mode';

  // Error Messages
    /// Error message for network issues
  static const String networkError = 'Network error occurred';
    /// Error message for when the user is offline
  static const String offlineError = 'You are currently offline';
    /// Error message for download issues
  static const String downloadError = 'Failed to download region';

    /// Error message when markers fail to load
  static const String unableToLoadMarkersError = 'Unable to load markers';
    /// Error message when download operation fails
  static const String downloadFailedError = 'Download failed: ';
   /// Error message when failed to download a region
  static const String failedToDownloadRegion = 'Failed to download region: ';
  // static const int defaultMaxZoomLevel = 13;
  // static const int defaultMinZoomLevel = 10;
   /// Mapbox streets style url
  static const String mapboxStreets = MapboxStyles.MAPBOX_STREETS;
}

/// enum to represent the download status
enum DownloadStatus {
  /// idle
  idle,
  /// downloading
  downloading,
  /// completed
  completed,
}