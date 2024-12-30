// lib/features/map/map_screen.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mobile/core/config/app_routes.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/map/map_viewmodel.dart';
import 'package:mobile/features/map/models/map_marker.dart' as map_marker;
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
  mb.MapboxMap? _mapboxMap;
  mb.PointAnnotationManager? _pointAnnotationManager;
  mb.PolylineAnnotationManager? _lineAnnotationManager;
  mb.PolygonAnnotationManager? _polygonAnnotationManager;
  late mb.CameraOptions _initialCameraOptions;
  final String mapStyle =
      AppConstants.mapboxStreets;
  final List<mb.PointAnnotation> _pointAnnotations = [];
  final List<mb.PolylineAnnotation> _lineAnnotations = [];
  final List<mb.PolygonAnnotation> _polygonAnnotations = [];
  bool _mapReady = false;
  StreamSubscription<bool>? _connectivitySubscription;
   final _errorKey = GlobalKey();

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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(mapViewModelProvider.notifier).loadMarkers();
    // });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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
            ref.listen(mapViewModelProvider, (previous, next) {
              if (next.message != null && next.message!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(next.message!)),
                );
              }
              if (next.error != null && _errorKey.currentState == null) {
                showDialog(
                  context: context,
                   builder: (context) => CustomErrorWidget(
                      key: _errorKey,
                      error: next.error!,
                   ),
                );
              }
            });
            return Stack(
              children: [
                mb.MapWidget(
                  styleUri: mapStyle,
                  cameraOptions: _initialCameraOptions,
                  onMapCreated: _onMapCreated,
                ),
                OfflineBanner(
                  isOffline: state.isOffline,
                ),
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
                if (state.isLoading && !state.isDownloadingRegion)
                  const LoadingOverlay(message: 'Loading Markers...'),
              ],
            );
          },
        ),
      );

  Future<void> _onMapCreated(mb.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    ref.read(mapViewModelProvider.notifier).setMap(mapboxMap);
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _lineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();
    _polygonAnnotationManager =
        await mapboxMap.annotations.createPolygonAnnotationManager();
    await _addMarkers();
    setState(() {
      _mapReady = true;
    });
  }

   Future<void> _addMarkers() async {
    if (_pointAnnotationManager == null ||
        _mapboxMap == null ||
        _lineAnnotationManager == null ||
        _polygonAnnotationManager == null) {
      return;
    }

    final state = ref.read(mapViewModelProvider);

    // Clear existing annotations
     if (_pointAnnotations.isNotEmpty) {
      for (final annotation in _pointAnnotations) {
        await _pointAnnotationManager?.delete(annotation);
      }
      _pointAnnotations.clear();
    }
    if (_lineAnnotations.isNotEmpty) {
      for (final annotation in _lineAnnotations) {
        await _lineAnnotationManager?.delete(annotation);
      }
      _lineAnnotations.clear();
    }
    if (_polygonAnnotations.isNotEmpty) {
      for (final annotation in _polygonAnnotations) {
        await _polygonAnnotationManager?.delete(annotation);
      }
      _polygonAnnotations.clear();
    }


    for (final marker in state.markers) {
      switch (marker.geometry.type) {
        case map_marker.GeometryType.point:
          final annotation = mb.PointAnnotationOptions(
            geometry: mb.Point(
              coordinates: mb.Position(
                  marker.geometry.coordinates[0], marker.geometry.coordinates[1],),
            ),
            textField: marker.title,
            textOffset: const [0.0, 2.0],
          );
          final createdAnnotation = await _pointAnnotationManager?.create(annotation);
             if(createdAnnotation != null){
               _pointAnnotations.add(createdAnnotation);
             }

          break;
        case map_marker.GeometryType.lineString:
          final coordinates = marker.geometry.coordinates
              .map((coord) => mb.Position(coord[0], coord[1]))
              .toList();
          final lineAnnotationOptions = mb.PolylineAnnotationOptions(
            geometry: mb.LineString(coordinates: coordinates),
            lineColor: Colors.red.value,
            lineWidth: 3,
          );
           final createdAnnotation = await _lineAnnotationManager?.create(lineAnnotationOptions);
           if(createdAnnotation != null){
            _lineAnnotations.add(createdAnnotation);
          }
          break;
        case map_marker.GeometryType.polygon:
          final coordinates = marker.geometry.coordinates[0]
              .map((coord) => mb.Position(coord[0], coord[1]))
              .toList();
          final polygonAnnotationOptions = mb.PolygonAnnotationOptions(
            geometry: mb.Polygon(coordinates: [coordinates]),
             fillColor: Colors.blue.withOpacity(0.3).value,
          );
           final createdAnnotation = await _polygonAnnotationManager?.create(polygonAnnotationOptions);
         if(createdAnnotation != null){
           _polygonAnnotations.add(createdAnnotation);
         }
          break;
      }
    }
  }
  Future<void> _downloadCurrentRegion() async {
    if (_mapboxMap == null || !_mapReady) {
      return;
    }

    try {
      final cameraState = await _mapboxMap!.getCameraState();

      final bounds = await _mapboxMap!.coordinateBoundsForCamera(
        mb.CameraOptions(
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

      await ref.read(mapViewModelProvider.notifier).getRegionSize(bounds);
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