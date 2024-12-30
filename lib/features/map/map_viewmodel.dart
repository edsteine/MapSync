// lib/features/map/map_viewmodel.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';
import 'package:mobile/features/map/map_repository.dart';
import 'package:mobile/shared/models/map_marker.dart' as map_marker;

// Custom exception for MapViewModel errors
class MapViewModelException implements Exception {
  MapViewModelException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'MapViewModelException: $message, $error, stackTrace: $stackTrace';
}

class MapState {
  MapState({
    this.isLoading = false,
    this.markers = const [],
    this.error,
    this.isOffline = false,
    this.didFetchSuccessfully = false,
    this.isLocationLoading = false,
    this.message,
  });
  final bool isLoading;
  final List<map_marker.MapMarker> markers;
  final String? error;
  final bool isOffline;
  final bool didFetchSuccessfully;
  final bool isLocationLoading;
  final String? message;

    MapState copyWith({
    bool? isLoading,
    List<map_marker.MapMarker>? markers,
    String? error,
    bool? isOffline,
    bool? didFetchSuccessfully,
        bool? isLocationLoading,
          String? message,
        }) =>
        MapState(
          isLoading: isLoading ?? this.isLoading,
          markers: markers ?? this.markers,
          error: error,
          isOffline: isOffline ?? this.isOffline,
          didFetchSuccessfully: didFetchSuccessfully ?? this.didFetchSuccessfully,
             isLocationLoading: isLocationLoading ?? this.isLocationLoading,
            message: message,
        );
}

final mapViewModelProvider = StateNotifierProvider<MapViewModel, MapState>(
  (ref) => MapViewModel(
    ref.watch(mapRepositoryProvider),
    ref.watch(mapServiceProvider),
    ref,
  ),
);

class MapViewModel extends StateNotifier<MapState> {
  MapViewModel(this._repository, this._mapService, this.ref)
      : super(MapState());
  final MapRepository _repository;
  final MapService _mapService;
  final StateNotifierProviderRef<MapViewModel, MapState> ref;
    MapboxMap? _map;
    void setMap(MapboxMap map) {
      _map = map;
      _mapService.init();
  }
  Future<void> loadMarkers({bool forceRefresh = false}) async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final markers = await _repository.getMarkers(forceRefresh: forceRefresh);
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        markers: markers,
        isOffline: false,
        didFetchSuccessfully: markers.isNotEmpty,
        message: markers.isNotEmpty
            ? '${markers.length} markers added from a total of ${markers.length} results'
            : null,
      );
       if (kDebugMode) {
          print('Loaded markers: ${markers.length}');
        }
         if (markers.isNotEmpty) {
           await moveToFirstMarker();
        }
    } on MapRepositoryException catch (e) {
      if(e.message.contains('loading from cache')){
          final markers = await _repository.getMarkers();
          if (!mounted) {
            return;
          }
        state = state.copyWith(
          isLoading: false,
          markers: markers,
          isOffline: true,
          didFetchSuccessfully: markers.isNotEmpty,
          message: '${markers.length} markers added from cache',
        );
           AppUtils.handleStateError(
          this,
          ref,
          state,
          e,
          e.message,
        );
          if (markers.isNotEmpty) {
           await moveToFirstMarker();
        }
      } else {
          AppUtils.handleStateError(
          this,
          ref,
          state,
          e,
           '${AppConstants.unableToLoadMarkersError}: ${e.toString()}',
        );
      }

    }
     on Exception catch (e) {
      AppUtils.handleStateError(
        this,
        ref,
        state,
        e,
        '${AppConstants.unableToLoadMarkersError}: ${e.toString()}',
      );
    }
  }
   Future<void> moveToFirstMarker() async {
     if(_map == null) {
         return;
     }
      if (state.markers.isNotEmpty) {
      final firstMarker = state.markers.first;
       if (firstMarker.geometry.coordinates.isNotEmpty && firstMarker.geometry.type == map_marker.GeometryType.point) {
          await _map?.flyTo(
            CameraOptions(
              center: Point(
                  coordinates: Position(
                      firstMarker.geometry.coordinates[0],
                      firstMarker.geometry.coordinates[1],
                  ),
              ),
              zoom: AppConstants.defaultZoom,
            ),
            MapAnimationOptions(duration: 200),
        );
      }
    }
  }
   Future<void> clearMarkers() async {
        if (!mounted) {
        return;
       }
    state = state.copyWith(markers: []);
  }

  Future<void> moveToCurrentLocation(MapboxMap map) async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(isLocationLoading: true);
    try {
      final permission = await PermissionService.requestLocationPermissions();
      if (permission == geo.LocationPermission.deniedForever) {
        state = state.copyWith(
          isLocationLoading: false,
          message:
              'Location permissions permanently denied, please enable in settings.',
        );
        return;
      }

      if (permission == geo.LocationPermission.denied) {
        state = state.copyWith(
          isLocationLoading: false,
          message: 'Location permissions denied, using default location.',
        );
        await map.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                AppConstants.defaultLongitude,
                AppConstants.defaultLatitude,
              ),
            ),
            zoom: AppConstants.defaultZoom,
          ),
          MapAnimationOptions(duration: 200),
        );

        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      await map.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: AppConstants.defaultZoom,
        ),
        MapAnimationOptions(duration: 200),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting current location: $e, StackTrace: $stackTrace');
      }
      state = state.copyWith(
        isLocationLoading: false,
        message: 'Error getting current location, using default location.',
      );
      await map.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              AppConstants.defaultLongitude,
              AppConstants.defaultLatitude,
            ),
          ),
          zoom: AppConstants.defaultZoom,
        ),
        MapAnimationOptions(duration: 200),
      );
    } finally {
      if (mounted) {
        state = state.copyWith(isLocationLoading: false);
      }
    }
  }
}