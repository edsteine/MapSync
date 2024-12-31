// lib/features/map/map_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mobile/core/config/app_routes.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/map/map_viewmodel.dart';
import 'package:mobile/shared/models/map_marker.dart' as map_marker;
import 'package:mobile/shared/widgets/custom_error_widget.dart';
import 'package:mobile/shared/widgets/loading_overlay.dart';
import 'package:mobile/shared/widgets/map_controls.dart';
import 'package:mobile/shared/widgets/map_widget.dart' as mapwidget;
import 'package:mobile/shared/widgets/offline_banner.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  mb.MapboxMap? _mapboxMap;
  mb.PointAnnotationManager? _pointAnnotationManager;
  late mb.CameraOptions _initialCameraOptions;
  final String mapStyle = AppConstants.mapboxStreets;
  final List<mb.PointAnnotation> _pointAnnotations = [];
  StreamSubscription<bool>? _connectivitySubscription;
  late final mb.OnPointAnnotationClickListener _pointAnnotationClickListener;
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
    _pointAnnotationClickListener = _PointAnnotationClickListener(this);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    // _pointAnnotationManager?.removeClickListener(_pointAnnotationClickListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Online Maps'),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(mapViewModelProvider.notifier).clearMarkers();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
            IconButton(
              icon: const Icon(Icons.offline_bolt),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.offlineMap);
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
              if (next.error != null && next.error!.isNotEmpty) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(next.error!)),
                // );
              }

              if (previous?.markers != next.markers) {
                _addMarkers();
              }
            });

            return Stack(
              children: [
                mapwidget.CustomMapWidget(
                  styleUri: mapStyle,
                  cameraOptions: _initialCameraOptions,
                  onMapCreated: _onMapCreated,
                ),
                OfflineBanner(
                  isOffline: state.isOffline,
                ),
                MapControls(
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  isLocationLoading: state.isLocationLoading,
                ),
                if (state.error != null && state.error!.isNotEmpty)
                  CustomErrorWidget(
                    error: state.error!,
                    onClose: () =>
                        ref.read(mapViewModelProvider.notifier).clearMarkers(),
                  ),
                if (state.isLoading)
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
    _pointAnnotationManager
        ?.addOnPointAnnotationClickListener(_pointAnnotationClickListener);
    await _addMarkers();
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

    for (final marker in state.markers) {
      if (marker.geometry.type == map_marker.GeometryType.point) {
        final annotation = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(
              marker.geometry.coordinates[0],
              marker.geometry.coordinates[1],
            ),
          ),
          iconImage: 'circle',
          iconColor: Colors.red.r.toInt(),
        );
        final createdAnnotation =
            await _pointAnnotationManager?.create(annotation);
        if (createdAnnotation != null) {
          createdAnnotation.id = marker.id;
          _pointAnnotations.add(createdAnnotation);
        }
      }
    }
    if (_mapboxMap != null) {
      await addCustomCircleImage();
    }
  }

  Future<void> addCustomCircleImage() async {
    final imageBytes = await _createCircleIcon(Colors.red);

    // Create MbxImage from bytes
    final mbxImage = mb.MbxImage(
      width: 20,
      height: 20,
      data: imageBytes,
    );

    // Add style image to the Mapbox style
    await _mapboxMap!.style.addStyleImage(
      'circle',
      1,
      mbxImage,
      false,
      [],
      [],
      null,
    );
  }

  Future<Uint8List> _createCircleIcon(Color color) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    const radius = 10.0;
    canvas.drawCircle(const Offset(radius, radius), radius, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(radius.toInt() * 2, radius.toInt() * 2);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  void _showMarkerInfo(BuildContext context, map_marker.MapMarker marker) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(marker.title),
        content: Text(marker.description),
        actions: <Widget>[
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

class _PointAnnotationClickListener extends mb.OnPointAnnotationClickListener {
  _PointAnnotationClickListener(this._state);
  final _MapScreenState _state;
  @override
  void onPointAnnotationClick(mb.PointAnnotation annotation) {
    if (annotation.id.isNotEmpty) {
      final marker = _state.ref
          .read(mapViewModelProvider)
          .markers
          .firstWhere((element) => element.id == annotation.id);
      _state._showMarkerInfo(_state.context, marker);
    }
  }
}
