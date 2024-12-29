// lib/features/map/map_screen.dart
// lib/features/map/map_screen.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/config/app_routes.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/map/map_viewmodel.dart';
import 'package:mobile/features/map/widgets/map_controls.dart';
import 'package:mobile/features/map/widgets/offline_banner.dart';
import 'package:mobile/shared/widgets/custom_error_widget.dart';
import 'package:mobile/shared/widgets/loading_overlay.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  late mb.CameraOptions _initialCameraOptions;
  final String mapStyle =
      AppConstants.mapboxStreets; // Choose your map style here.
  List<mb.PointAnnotation> _pointAnnotations = [];
  bool _mapReady = false; // Track if the map has been initialized

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
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Offline Maps'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref
                  .read(mapViewModelProvider.notifier)
                  .loadMarkers(forceRefresh: true),
            ),
          ],
        ),
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final state = ref.watch(mapViewModelProvider);
            return Stack(
              children: [
                MapWidget(
                  styleUri: mapStyle,
                  cameraOptions: _initialCameraOptions,
                  onMapCreated: _onMapCreated,
                ),
                if (state.isOffline) const OfflineBanner(),
                MapControls(
                  onDownloadRegion: _downloadCurrentRegion,
                  isDownloading: state.isDownloadingRegion,
                  downloadProgress: state.downloadProgress ?? 0.0,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  isLocationLoading: state.isLocationLoading,
                  regionSize: state.regionSize,
                ),
                if (state.error != null) CustomErrorWidget(error: state.error!),
                if (state.isLoading && !state.isDownloadingRegion)
                  const LoadingOverlay(message: 'Loading Markers...'),
              ],
            );
          },
        ),
      );

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    ref.read(mapViewModelProvider.notifier).setMap(mapboxMap);
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    await _addMarkers();
    setState(() {
      _mapReady = true; // Mark map as ready after initialization
    });
  }

  Future<void> _addMarkers() async {
    if (_pointAnnotationManager == null || _mapboxMap == null) {
      return;
    }
    final state = ref.read(mapViewModelProvider);
    if (_pointAnnotations.isNotEmpty) {
      for (final annotation in _pointAnnotations) {
        await _pointAnnotationManager?.delete(annotation);
      }
      _pointAnnotations.clear();
    }
    final annotations = state.markers
        .map(
          (marker) => mb.PointAnnotationOptions(
            geometry: mb.Point(
              coordinates: mb.Position(marker.longitude, marker.latitude),
            ),
            textField: marker.title,
            textOffset: [0.0, 2.0],
          ),
        )
        .toList();

    if (annotations.isNotEmpty) {
      final createdAnnotations =
          await _pointAnnotationManager?.createMulti(annotations) ?? [];
      _pointAnnotations =
          createdAnnotations.whereType<mb.PointAnnotation>().toList();
    }
  }

  Future<void> _downloadCurrentRegion() async {
    if (_mapboxMap == null || !_mapReady) {
      return;
    }

    try {
      final cameraState = await _mapboxMap!.getCameraState();

      // Get bounds using the camera state
      final bounds = await _mapboxMap!.coordinateBoundsForCamera(
        CameraOptions(
          center: cameraState.center,
          zoom: cameraState.zoom,
          bearing: cameraState.bearing,
          pitch: cameraState.pitch,
        ),
      );

      if (kDebugMode) {
        print('Southwest: ${bounds.southwest.coordinates}');
        print('Northeast: ${bounds.northeast.coordinates}');
      }
      await ref.read(mapViewModelProvider.notifier).downloadRegion(bounds);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error fetching bounds or download region: $e');
      }
    }
  }

  Future<void> _zoomIn() async {
    if (_mapboxMap == null) {
      return;
    }
    final currentZoom =
        await _mapboxMap!.getCameraState().then((value) => value.zoom);
    await _mapboxMap!.flyTo(
      mb.CameraOptions(zoom: currentZoom + 1),
      mb.MapAnimationOptions(duration: 200),
    );
  }

  Future<void> _zoomOut() async {
    if (_mapboxMap == null) {
      return;
    }
    final currentZoom =
        await _mapboxMap!.getCameraState().then((value) => value.zoom);
    await _mapboxMap!.flyTo(
      mb.CameraOptions(zoom: currentZoom - 1),
      mb.MapAnimationOptions(duration: 200),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    if (_mapboxMap == null) {
      return;
    }
    await ref
        .read(mapViewModelProvider.notifier)
        .moveToCurrentLocation(_mapboxMap!);
  }
}
