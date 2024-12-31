///
/// File: lib/features/offline_map/offline_map_screen.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays the offline map screen, including controls for downloading and managing offline map regions.
/// Updates: Initial setup with a map widget, download dialog, regions management, zoom controls and current location functionalities.
/// Used Libraries: flutter/foundation.dart, flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/utils/app_constants.dart, mobile/core/utils/error_manager.dart, mobile/features/offline_map/offline_map_viewmodel.dart, mobile/shared/widgets/custom_error_widget.dart, mobile/shared/widgets/loading_overlay.dart, mobile/shared/widgets/map_controls.dart, mobile/shared/widgets/region_item.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/error_manager.dart';
import 'package:mobile/features/offline_map/offline_map_viewmodel.dart';
import 'package:mobile/shared/widgets/custom_error_widget.dart';
import 'package:mobile/shared/widgets/loading_overlay.dart';
import 'package:mobile/shared/widgets/map_controls.dart';
import 'package:mobile/shared/widgets/region_item.dart';

/// OfflineMapScreen provides UI for displaying and managing offline map regions.
class OfflineMapScreen extends ConsumerStatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  ConsumerState<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends ConsumerState<OfflineMapScreen> {
    /// Mapbox map object, which is going to be initialized once the map has been created.
  MapboxMap? _mapboxMap;
    /// Camera options for setting the initial map view
  late mb.CameraOptions _initialCameraOptions;
    ///  Selected city to download a region.
  String _selectedCity = '';

  /// Map with different cities configurations
  final Map<String, Map<String, double>> _cities = {
    'Casablanca': {
      'latitude': 33.5731104,
      'longitude': -7.5898434,
      'zoom': 11.0,
    },
    'Rabat': {
      'latitude': 34.020882,
      'longitude': -6.832477,
      'zoom': 11.0,
    },
    'Paris': {
      'latitude': 48.8566,
      'longitude': 2.3522,
      'zoom': 11.0,
    },
    'New York': {
      'latitude': 40.7128,
      'longitude': -74.0060,
      'zoom': 11.0,
    },
  };

  @override
  void initState() {
    super.initState();
    // Sets the default camera options for the map
    _initialCameraOptions = mb.CameraOptions(
      center: mb.Point(
        coordinates: mb.Position(
          AppConstants.defaultLongitude,
          AppConstants.defaultLatitude,
        ),
      ),
      zoom: AppConstants.defaultZoom,
    );
    // Loads the downloaded regions after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlineMapViewModelProvider.notifier).loadRegions();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // AppBar for the offline map screen
        appBar: AppBar(
          title: const Text('Offline Maps'),
           // Action buttons for downloading regions and managing the downloaded regions.
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _showDownloadDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => _showRegionsDialog(context),
            ),
          ],
        ),
        // Main body with a stack of elements.
        body: Stack(
          children: [
             // Map widget to display offline maps
            MapWidget(
              // styleUri: MapboxStyles.STANDARD,
              cameraOptions: _initialCameraOptions,
              onMapCreated: _onMapCreated,
            ),
             // Consumer for displaying error message
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final errorState = ref.watch(errorProvider);
                return errorState.message != null
                    ? CustomErrorWidget(
                        error: errorState.message!,
                        onClose: () =>
                            ref.read(errorProvider.notifier).clearError(),
                      )
                    : const SizedBox();
              },
            ),
            // Consumer for showing loading indicator while a region is being downloaded.
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final state = ref.watch(offlineMapViewModelProvider);
                return state.downloadStatus == DownloadStatus.downloading
                    ? LoadingOverlay(
                        message:
                            'Downloading Style Pack... ${(state.stylePackProgress * 100).toInt()}% \n Downloading Tiles... ${(state.downloadProgress * 100).toInt()}%',
                      )
                    : const SizedBox();
              },
            ),
           // Consumer for displaying the map zoom and current location buttons
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final state = ref.watch(offlineMapViewModelProvider);
                return MapControls(
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  isLocationLoading: state.isLocationLoading,
                );
              },
            ),
          ],
        ),
      );

   /// Callback called when the map has been created, updates the `_mapboxMap` variable.
  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
  }

    /// Downloads the currently selected city's map region.
  Future<void> _downloadCity(BuildContext context) async {
    try {
      // Checks if a city has been selected before starting the download process
      if (_selectedCity.isEmpty) {
        return;
      }
      // Gets the city configurations
      final city = _cities[_selectedCity]!;
        // Gets the coordinate bounds of the city using the current map
      final bounds = await _mapboxMap!.coordinateBoundsForCamera(
        CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(
              city['longitude']!,
              city['latitude']!,
            ),
          ),
          zoom: city['zoom'],
        ),
      );
       // Prints download information when debug mode is enabled.
      if (kDebugMode) {
        print('Downloading city: $_selectedCity');
        print(
          'Southwest: lng: ${bounds.southwest.coordinates.lng}, lat: ${bounds.southwest.coordinates.lat}',
        );
        print(
          'Northeast: lng: ${bounds.northeast.coordinates.lng}, lat: ${bounds.northeast.coordinates.lat}',
        );
        print('Zoom levels: min: 1, max: 20');
        print('Starting download');
      }
      // Downloads the selected region, if the widget is still mounted.
      if (mounted) {
         // Pops up the dialog if the context is mounted.
        if (context.mounted) {
          Navigator.of(context).pop();
          await ref.read(offlineMapViewModelProvider.notifier).downloadRegion(
                bounds: bounds,
                minZoom: 1,
                maxZoom: 20,
                onProgress: (progress) {
                  if (kDebugMode) {
                    print('Download progress: ${progress * 100}%');
                  }
                },
                onComplete: () async {
                   // Prints to the console when the download is completed.
                  if (kDebugMode) {
                    final size = await ref
                        .read(offlineMapViewModelProvider.notifier)
                        .getRegionSize(bounds);
                    print('Download complete. Approximate size: $size');
                  }
                },
              );
        }
      }
      // Catches any exception that happens during the region download process
    } on Exception catch (e) {
      // Prints to the console if there is any error during download.
      if (kDebugMode) {
        print('Error fetching bounds or downloading region: $e');
      }
    }
  }

  /// Displays a dialog for downloading map regions.
  Future<void> _showDownloadDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Region'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a City to Download'),
              const SizedBox(height: 16),
               // Dropdown button to select a city.
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'City',
                ),
                items: _cities.keys
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  _selectedCity = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              // Download button to trigger download of the selected city region.
              ElevatedButton(
                onPressed: () => _downloadCity(context),
                child: const Text('Download'),
              ),
            ],
          ),
        ),
         // Action buttons to close or submit the form
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

   /// Displays a dialog for managing downloaded map regions.
  Future<void> _showRegionsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Downloaded Regions'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final state = ref.watch(offlineMapViewModelProvider);
              return state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                   // List view that maps the downloaded regions.
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.regions.length,
                      itemBuilder: (context, index) => RegionItem(
                        region: state.regions[index],
                        deleteRegion: (regionId) {
                          ref
                              .read(offlineMapViewModelProvider.notifier)
                              .deleteRegion(regionId);
                        },
                      ),
                    );
            },
          ),
        ),
         // Action button to close the dialog.
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

   /// Zooms in on the map using the flyTo method with animation.
  Future<void> _zoomIn() async {
    if (_mapboxMap == null) {
      return;
    }
    final currentZoom =
        await _mapboxMap!.getCameraState().then((value) => value.zoom);
    await _mapboxMap!.flyTo(
      CameraOptions(zoom: currentZoom + 1),
      MapAnimationOptions(duration: 200),
    );
  }

    /// Zooms out on the map using the flyTo method with animation.
  Future<void> _zoomOut() async {
    if (_mapboxMap == null) {
      return;
    }
    final currentZoom =
        await _mapboxMap!.getCameraState().then((value) => value.zoom);
    await _mapboxMap!.flyTo(
      CameraOptions(zoom: currentZoom - 1),
      MapAnimationOptions(duration: 200),
    );
  }

    /// Moves the map camera to the current device location using the `moveToCurrentLocation` method from the view model.
  Future<void> _moveToCurrentLocation() async {
    if (_mapboxMap == null) {
      return;
    }
    await ref
        .read(offlineMapViewModelProvider.notifier)
        .moveToCurrentLocation(_mapboxMap!);
  }
}