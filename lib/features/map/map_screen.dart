///
/// File: lib/features/map/map_screen.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays the main map screen, including rendering the map, handling map events, and showing markers.
/// Updates: Initial setup with Mapbox integration, dynamic marker display, and UI controls such as clear, settings, offline and refresh buttons. Also provides support for showing map markers info, zoom in, zoom out and move to the current location
/// Used Libraries: dart/async.dart, dart/typed_data.dart, dart/ui.dart, flutter/foundation.dart, flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/config/app_routes.dart, mobile/core/utils/app_constants.dart, mobile/features/map/map_viewmodel.dart, mobile/shared/models/map_marker.dart, mobile/shared/widgets/custom_error_widget.dart, mobile/shared/widgets/loading_overlay.dart, mobile/shared/widgets/map_controls.dart, mobile/shared/widgets/map_widget.dart, mobile/shared/widgets/offline_banner.dart
///
library;
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

/// MapScreen displays the main map with markers and provides UI elements for different actions.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
   /// Mapbox map object for map interaction
  mb.MapboxMap? _mapboxMap;
   ///  Point annotation manager used for managing markers on the map.
  mb.PointAnnotationManager? _pointAnnotationManager;
   ///  Camera options for setting the initial map view
  late mb.CameraOptions _initialCameraOptions;
   /// Default map style url.
  final String mapStyle = AppConstants.mapboxStreets;
   /// List for managing point annotations for map markers.
  final List<mb.PointAnnotation> _pointAnnotations = [];
    /// Subscription for connectivity changes.
  StreamSubscription<bool>? _connectivitySubscription;
  /// Listener for clicks on map markers
  late final mb.OnPointAnnotationClickListener _pointAnnotationClickListener;
  
  @override
  void initState() {
    super.initState();
    // Sets the default camera options
    _initialCameraOptions = mb.CameraOptions(
      center: mb.Point(
        coordinates: mb.Position(
          AppConstants.defaultLongitude,
          AppConstants.defaultLatitude,
        ),
      ),
      zoom: AppConstants.defaultZoom,
    );
    // Setting up point click listener
    _pointAnnotationClickListener = _PointAnnotationClickListener(this);
  }

  @override
  void dispose() {
      //Cancels the connectivity subscription when the screen is disposed
    _connectivitySubscription?.cancel();
    // _pointAnnotationManager?.removeClickListener(_pointAnnotationClickListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      // AppBar of the application
        appBar: AppBar(
          title: const Text('Online Maps'),
           // List of action buttons for the map screen.
          actions: [
            IconButton(
               // Button to clear the map markers.
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(mapViewModelProvider.notifier).clearMarkers();
              },
            ),
            IconButton(
              // Button to open the settings screen.
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
             // Button to open the offline map screen.
            IconButton(
              icon: const Icon(Icons.offline_bolt),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.offlineMap);
              },
            ),
              // Button to refresh map markers
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref
                  .read(mapViewModelProvider.notifier)
                  .loadMarkers(forceRefresh: true),
            ),
          ],
        ),
        // Main body of the app
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final state = ref.watch(mapViewModelProvider);
             // Sets a listener to show a snack bar if a message is added to the state, also updates the markers if a change has occurred
            ref.listen(mapViewModelProvider, (previous, next) {
                // Checks if there is a new message from the state, and if so shows a snack bar
              if (next.message != null && next.message!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(next.message!)),
                );
              }
                // Check if there are any errors that have been set and shows a snackbar if there is any.
              if (next.error != null && next.error!.isNotEmpty) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(next.error!)),
                // );
              }

              // Add's markers if there has been any changes
              if (previous?.markers != next.markers) {
                _addMarkers();
              }
            });

            return Stack(
              children: [
                 // Map widget to display the map
                mapwidget.CustomMapWidget(
                  styleUri: mapStyle,
                  cameraOptions: _initialCameraOptions,
                  onMapCreated: _onMapCreated,
                ),
                // Shows the banner if the app is offline
                OfflineBanner(
                  isOffline: state.isOffline,
                ),
                 // Displays map controls to zoom in, zoom out and move to the current location.
                MapControls(
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  isLocationLoading: state.isLocationLoading,
                ),
                // Custom error widget for displaying errors from the view model.
                if (state.error != null && state.error!.isNotEmpty)
                  CustomErrorWidget(
                    error: state.error!,
                    onClose: () =>
                        ref.read(mapViewModelProvider.notifier).clearMarkers(),
                  ),
                 // Loading overlay for displaying while the markers are loading.
                if (state.isLoading)
                  const LoadingOverlay(message: 'Loading Markers...'),
              ],
            );
          },
        ),
      );

   /// Callback when map has been created, initializes point annotation manager, sets map to view model and adds all markers
  Future<void> _onMapCreated(mb.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
     // Sets the map instance into the view model.
    ref.read(mapViewModelProvider.notifier).setMap(mapboxMap);
    // Creates the point annotation manager to manage the map markers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    // Sets the point annotation click listener
    _pointAnnotationManager
        ?.addOnPointAnnotationClickListener(_pointAnnotationClickListener);
        // Add's the markers to the map.
    await _addMarkers();
  }

    /// Adds the markers to the map, using point annotation manager.
  Future<void> _addMarkers() async {
      // Returns early if the manager is null
    if (_pointAnnotationManager == null || _mapboxMap == null) {
      return;
    }

    final state = ref.read(mapViewModelProvider);

     // Remove all existing annotations before adding new ones.
    if (_pointAnnotations.isNotEmpty) {
      for (final annotation in _pointAnnotations) {
        await _pointAnnotationManager?.delete(annotation);
      }
      _pointAnnotations.clear();
    }

     // Iterates over the markers in the state and adds them to the map
    for (final marker in state.markers) {
      if (marker.geometry.type == map_marker.GeometryType.point) {
         //  Creates an annotation using the given coordinates.
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
        // Creates the annotation to the map, using the annotation manager
        final createdAnnotation =
            await _pointAnnotationManager?.create(annotation);
        if (createdAnnotation != null) {
          createdAnnotation.id = marker.id;
          _pointAnnotations.add(createdAnnotation);
        }
      }
    }
       // Adds the custom circle image to the map.
    if (_mapboxMap != null) {
      await addCustomCircleImage();
    }
  }

   /// Adds a custom circle image for the markers, used for map annotation icons.
  Future<void> addCustomCircleImage() async {
    // Create the custom circle image using a helper function.
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

   /// Creates a circle icon as a Uint8List, used to display a custom icon on the map.
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

   /// Shows information about the selected marker in an alert dialog
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

  /// Zooms in on the map using the flyTo method with animation.
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

   /// Zooms out on the map using the flyTo method with animation.
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

   /// Moves the map to the current device location using the view model
  Future<void> _moveToCurrentLocation() async {
    if (_mapboxMap == null) {
      return;
    }
    await ref
        .read(mapViewModelProvider.notifier)
        .moveToCurrentLocation(_mapboxMap!);
  }
}

/// Listener class for clicks on point annotations, it shows a dialog when clicked.
class _PointAnnotationClickListener extends mb.OnPointAnnotationClickListener {
    ///  Constructor takes the state of the map screen as an argument.
  _PointAnnotationClickListener(this._state);
   /// State of the map screen, allowing the listener to access to the methods and view models of the map screen
  final _MapScreenState _state;
  @override
  void onPointAnnotationClick(mb.PointAnnotation annotation) {
      // Checks if the annotation has an id before showing the marker info.
    if (annotation.id.isNotEmpty) {
       // Get the marker associated to the current annotation, using it's id.
      final marker = _state.ref
          .read(mapViewModelProvider)
          .markers
          .firstWhere((element) => element.id == annotation.id);
          // Shows the marker info in a dialog.
      _state._showMarkerInfo(_state.context, marker);
    }
  }
}