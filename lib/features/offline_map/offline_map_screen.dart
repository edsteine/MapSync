// lib/features/offline_map/offline_map_screen.dart
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

class OfflineMapScreen extends ConsumerStatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  ConsumerState<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends ConsumerState<OfflineMapScreen> {
  MapboxMap? _mapboxMap;
  late mb.CameraOptions _initialCameraOptions;
  String _selectedCity = '';

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
    _initialCameraOptions = mb.CameraOptions(
      center: mb.Point(
        coordinates: mb.Position(
          AppConstants.defaultLongitude,
          AppConstants.defaultLatitude,
        ),
      ),
      zoom: AppConstants.defaultZoom,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlineMapViewModelProvider.notifier).loadRegions();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Offline Maps'),
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
        body: Stack(
          children: [
            MapWidget(
              // styleUri: MapboxStyles.STANDARD,
              cameraOptions: _initialCameraOptions,
              onMapCreated: _onMapCreated,
            ),
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

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
  }

  Future<void> _downloadCity(BuildContext context) async {
    try {
      if (_selectedCity.isEmpty) {
        return;
      }
      final city = _cities[_selectedCity]!;
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

      if (mounted) {
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
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error fetching bounds or downloading region: $e');
      }
    }
  }

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
              ElevatedButton(
                onPressed: () => _downloadCity(context),
                child: const Text('Download'),
              ),
            ],
          ),
        ),
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

  Future<void> _moveToCurrentLocation() async {
    if (_mapboxMap == null) {
      return;
    }
    await ref
        .read(offlineMapViewModelProvider.notifier)
        .moveToCurrentLocation(_mapboxMap!);
  }
}
