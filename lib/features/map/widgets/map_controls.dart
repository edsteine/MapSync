// lib/features/map/widgets/map_controls.dart
import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  const MapControls({
    required this.onDownloadRegion,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMoveToCurrentLocation,
    super.key,
    this.regionSize,
    this.isLocationLoading = false,
  });
  final VoidCallback onDownloadRegion;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMoveToCurrentLocation;
  final String? regionSize;
  final bool isLocationLoading;

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (regionSize != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Approx. Size: $regionSize'),
              ),
            if (isDownloading)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CircularProgressIndicator(
                  value: downloadProgress,
                ),
              )
            else
              FloatingActionButton(
                heroTag: 'download',
                onPressed: onDownloadRegion,
                child: const Icon(Icons.download),
              ),
            const SizedBox(height: 8), // space
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
