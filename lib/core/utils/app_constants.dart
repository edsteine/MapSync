// lib/core/utils/constants.dart
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class AppConstants {
  // Map Constants
  static const double defaultLongitude = -7.6351861;
  static const double defaultLatitude = 33.5724805;

  static const double defaultZoom = 14;
  static const int minZoom = 0;
  static const int maxZoom = 22;

  static const String channelId = 'channelId';
  static const String channelName = 'channelName';
  static const String channelDescription = 'channelDescription';
  // Storage Keys
  static const String markersKey = 'markers';
  static const String themeModeKey = 'theme_mode';

  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String offlineError = 'You are currently offline';
  static const String downloadError = 'Failed to download region';

  // Error Messages
  static const String unableToLoadMarkersError = 'Unable to load markers';
  static const String downloadFailedError = 'Download failed: ';
  static const String failedToDownloadRegion = 'Failed to download region: ';
  // static const int defaultMaxZoomLevel = 13;
  // static const int defaultMinZoomLevel = 10;
  static const String mapboxStreets = MapboxStyles.MAPBOX_STREETS;
}

enum DownloadStatus {
  idle,
  downloading,
  completed,
}
