import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class CustomMapWidget extends StatelessWidget {
  const CustomMapWidget({
    required this.cameraOptions,
    required this.onMapCreated,
    required this.styleUri,
    
    super.key,
  });
  final CameraOptions cameraOptions;
  final void Function(MapboxMap) onMapCreated;
  final String styleUri;

  @override
  Widget build(BuildContext context) => MapWidget(
        styleUri: styleUri,
        cameraOptions: cameraOptions,
        onMapCreated: onMapCreated,

      );

      
}