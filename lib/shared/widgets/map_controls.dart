// lib/features/map/widgets/map_controls.dart
import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  const MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMoveToCurrentLocation,
    super.key,
     this.isLocationLoading = false,
  });
   final VoidCallback onZoomIn;
   final VoidCallback onZoomOut;
  final VoidCallback onMoveToCurrentLocation;
  final bool isLocationLoading;

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'zoom_in',
              mini: true,
              onPressed: onZoomIn,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8), // space
            FloatingActionButton(
              heroTag: 'zoom_out',
              mini: true,
              onPressed: onZoomOut,
              child: const Icon(Icons.remove),
            ),
              const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'my_location',
                mini: true,
               onPressed: onMoveToCurrentLocation,
               child: isLocationLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2,)) : const Icon(Icons.my_location),
            ),
          ],
        ),
      );
}