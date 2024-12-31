///
/// File: lib/shared/widgets/map_widget.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays the Mapbox map with provided configurations.
/// Updates: Initial setup with Mapbox MapWidget and camera options.
/// Used Libraries: flutter/material.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart
///
library;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// CustomMapWidget is a wrapper around the Mapbox MapWidget to specify custom configurations.
class CustomMapWidget extends StatelessWidget {
  const CustomMapWidget({
    required this.cameraOptions,
    required this.onMapCreated,
    required this.styleUri,
    super.key,
  });
  /// Camera options for setting the initial map view
  final CameraOptions cameraOptions;
   /// Callback for when the map has been created
  final void Function(MapboxMap) onMapCreated;
   /// Style uri for mapbox map to display
  final String styleUri;

  @override
  Widget build(BuildContext context) => MapWidget(
        styleUri: styleUri,
        cameraOptions: cameraOptions,
        onMapCreated: onMapCreated,
        androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
      );
}