// lib/features/map/map_viewmodel.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/map/map_repository.dart';
import 'package:mobile/features/map/models/map_marker.dart';

// Custom exception for MapViewModel errors
class MapViewModelException implements Exception {
  MapViewModelException(this.message);
  final String message;

  @override
  String toString() => 'MapViewModelException: $message';
}

class MapState {
  MapState({
    this.isLoading = false,
    this.markers = const [],
    this.error,
    this.isOffline = false,
    this.downloadProgress,
    this.didFetchSuccessfully = false,
    this.regionSize,
    this.isLocationLoading = false,
    this.isDownloadingRegion = false,
    this.maxZoomLevel = 13,
    this.minZoomLevel = 10,
  });
  final bool isLoading;
  final List<MapMarker> markers;
  final String? error;
  final bool isOffline;
  final double? downloadProgress;
  final bool didFetchSuccessfully;
  final String? regionSize;
  final bool isLocationLoading;
  final bool isDownloadingRegion;
  final int maxZoomLevel;
  final int minZoomLevel;

  MapState copyWith({
    bool? isLoading,
    List<MapMarker>? markers,
    String? error,
    bool? isOffline,
    double? downloadProgress,
    bool? didFetchSuccessfully,
    String? regionSize,
    bool? isLocationLoading,
    bool? isDownloadingRegion,
    int? maxZoomLevel,
    int? minZoomLevel,
  }) =>
      MapState(
        isLoading: isLoading ?? this.isLoading,
        markers: markers ?? this.markers,
        error: error,
        isOffline: isOffline ?? this.isOffline,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        didFetchSuccessfully: didFetchSuccessfully ?? this.didFetchSuccessfully,
        regionSize: regionSize ?? this.regionSize,
        isLocationLoading: isLocationLoading ?? this.isLocationLoading,
        isDownloadingRegion: isDownloadingRegion ?? this.isDownloadingRegion,
        maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
        minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      );
}

final mapViewModelProvider = StateNotifierProvider<MapViewModel, MapState>(
  (ref) => MapViewModel(
    ref.watch(mapRepositoryProvider),
    ref.watch(mapServiceProvider),
  ),
);

class MapViewModel extends StateNotifier<MapState> {
  MapViewModel(this._repository, this._mapService) : super(MapState()) {
    // loadMarkers();
    _listenToDownloadProgress();
  }
  final MapRepository _repository;
  final MapService _mapService;
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  Stream<double> get downloadProgress => _progressController.stream;

  void _listenToDownloadProgress() {
    downloadProgress.listen(
      (progress) {
        if (!mounted) {
          return;
        }
        state = state.copyWith(downloadProgress: progress);
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        state = state.copyWith(
          error: '${AppConstants.downloadFailedError} $error',
          isDownloadingRegion: false,
        );
      },
    );
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
        isLoading: false, // Set isLoading to false after success
        markers: markers,
        isOffline: false,
        didFetchSuccessfully: true,
      );
    } on Exception catch (e) {
       if (!mounted) {
        return;
      }
       state = state.copyWith(
        isLoading: false, // Set isLoading to false if there's an error
        error: '${AppConstants.unableToLoadMarkersError}: ${e.toString()}',
        isOffline: true,
        didFetchSuccessfully: false,
      );
    }
  }

  Future<void> downloadRegion(CoordinateBounds bounds) async {
    if (!mounted) {
      return;
    }

    try {
      state = state.copyWith(
        isDownloadingRegion: true,
        downloadProgress: 0,
      );
      await _mapService.downloadRegion(
        regionName: 'region_${DateTime.now().millisecondsSinceEpoch}',
        bounds: bounds,
        onProgress: (progress) {
          if (!mounted) {
            return;
          }
          _progressController.add(progress);
          state = state.copyWith(downloadProgress: progress);
        },
        onComplete: () {
          if (!mounted) {
            return;
          }
          state = state.copyWith(isDownloadingRegion: false);
          _progressController.add(1);
        },
         onError: (e) {
          if (!mounted) {
            return;
          }
            state = state.copyWith(
            error: e.toString(),
            isDownloadingRegion: false,
          );
        },
        maxZoom: state.maxZoomLevel,
        minZoom: state.minZoomLevel,
      );
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
        state = state.copyWith(
          error: e.toString(),
          isDownloadingRegion: false,
        );
    }
  }

  Future<void> moveToCurrentLocation(MapboxMap map) async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(isLocationLoading: true);
    try {
      final permission = await PermissionService.requestLocationPermissions();
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }
        state = state.copyWith(isLocationLoading: false);
        {
          return;
        }
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
    } on Exception catch (e) { // Added on Exception here
      // Do nothing. Use default location.
       if (kDebugMode) {
        print('Error getting current location: $e');
      }
      state = state.copyWith(isLocationLoading: false);
    } finally {
      if (mounted) {
        state = state.copyWith(isLocationLoading: false);
      }
    }
  }

  void setMap(MapboxMap map) {
    _mapService.init();
  }

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }
}