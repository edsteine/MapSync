///
/// File: lib/shared/widgets/map_controls.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays map controls such as zoom in, zoom out, and move to current location on the map.
/// Updates: Initial setup of map controls with zoom in, zoom out, and current location actions.
/// Used Libraries: flutter/material.dart
///
library;
import 'package:flutter/material.dart';

/// MapControls widget provides the UI controls for map zoom and current location.
class MapControls extends StatelessWidget {
    /// Constructor for the MapControls widget, takes callbacks for zoom in, zoom out and move to current location.
  const MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMoveToCurrentLocation,
    super.key,
    this.isLocationLoading = false,
  });
   /// Callback function called when the zoom in button is clicked.
  final VoidCallback onZoomIn;
    /// Callback function called when the zoom out button is clicked.
  final VoidCallback onZoomOut;
  /// Callback function called when the move to current location button is clicked.
  final VoidCallback onMoveToCurrentLocation;
    /// Location loading state to disable location button and show loader.
  final bool isLocationLoading;

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              //  Floating action button for zoom in.
            FloatingActionButton(
              heroTag: 'zoom_in',
              mini: true,
              onPressed: onZoomIn,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8), // space
             //  Floating action button for zoom out.
            FloatingActionButton(
              heroTag: 'zoom_out',
              mini: true,
              onPressed: onZoomOut,
              child: const Icon(Icons.remove),
            ),
            const SizedBox(height: 8),
              //  Floating action button for the move to the current location functionality.
            FloatingActionButton(
              heroTag: 'my_location',
              mini: true,
              onPressed: onMoveToCurrentLocation,
              child: isLocationLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ],
        ),
      );
}