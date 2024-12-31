// lib/features/offline_map/offline_map_viewmodel.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';
import 'package:mobile/features/offline_map/offline_map_repository.dart';

// Custom exception for OfflineMapViewModel errors
class OfflineMapViewModelException implements Exception {
  OfflineMapViewModelException(this.message, this.error);
  final String message;
  final dynamic error;

  @override
  String toString() => 'OfflineMapViewModelException: $message, $error';
}

class OfflineMapState {
  OfflineMapState({
    this.isLoading = false,
    this.regions = const [],
    this.error,
    this.downloadStatus = DownloadStatus.idle,
    this.isLocationLoading = false,
    this.message,
    this.downloadProgress = 0,
    this.stylePackProgress = 0,
  });
  final bool isLoading;
  final List<TileRegion> regions;
  final String? error;
  final DownloadStatus downloadStatus;
  final bool isLocationLoading;
  final String? message;
  final double downloadProgress;
  final double stylePackProgress;

  OfflineMapState copyWith({
    bool? isLoading,
    List<TileRegion>? regions,
    String? error,
    DownloadStatus? downloadStatus,
    bool? isLocationLoading,
    String? message,
    double? downloadProgress,
    double? stylePackProgress,
  }) =>
      OfflineMapState(
        isLoading: isLoading ?? this.isLoading,
        regions: regions ?? this.regions,
        error: error,
        downloadStatus: downloadStatus ?? this.downloadStatus,
        isLocationLoading: isLocationLoading ?? this.isLocationLoading,
        message: message,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        stylePackProgress: stylePackProgress ?? this.stylePackProgress,
      );
}

final offlineMapViewModelProvider =
    StateNotifierProvider.autoDispose<OfflineMapViewModel, OfflineMapState>(
  (ref) => OfflineMapViewModel(
    ref.watch(offlineMapRepositoryProvider),
    ref,
    ref.watch(mapServiceProvider),
  ),
);

class OfflineMapViewModel extends StateNotifier<OfflineMapState> {
  OfflineMapViewModel(this._repository, this.ref, this._mapService)
      : super(OfflineMapState());
  final OfflineMapRepository _repository;
  final Ref ref;
  final MapService _mapService;
  StreamSubscription<double>? _stylePackSubscription;
  StreamSubscription<double>? _tileRegionSubscription;

  void updateState(OfflineMapState newState) {
    state = newState;
  }

  Future<void> loadRegions() async {
    if (!mounted) {
      return;
    }
    updateState(state.copyWith(isLoading: true));
    try {
      final regions = await _repository.getDownloadedRegions();
      if (!mounted) {
        return;
      }
      updateState(state.copyWith(regions: regions, isLoading: false));
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

  Future<void> downloadRegion({
    required CoordinateBounds bounds,
    required int minZoom,
    required int maxZoom,
    required void Function(double) onProgress,
    required void Function() onComplete,
  }) async {
    if (!mounted) {
      return;
    }
    updateState(
      state.copyWith(
        downloadStatus: DownloadStatus.downloading,
        downloadProgress: 0,
        stylePackProgress: 0,
      ),
    );
    _stylePackSubscription = _mapService.stylePackProgress.listen((progress) {
      if (mounted) {
        updateState(state.copyWith(stylePackProgress: progress));
      }
      if (kDebugMode) {
        print('Style pack progress: ${progress * 100}%');
      }
    });
    _tileRegionSubscription = _mapService.tileRegionProgress.listen((progress) {
      if (mounted) {
        updateState(state.copyWith(downloadProgress: progress));
      }
      if (kDebugMode) {
        print('Tile region progress: ${progress * 100}%');
      }
    });
    try {
      await _repository.downloadRegion(
        regionName: 'region_${DateTime.now().millisecondsSinceEpoch}',
        bounds: bounds,
        onProgress: (progress) {
          if (kDebugMode) {
            print('Download progress: ${progress * 100}%');
          }
        },
        onComplete: () {
          if (mounted) {
            updateState(
              state.copyWith(downloadStatus: DownloadStatus.completed),
            );
            loadRegions();
          }
        },
        onError: (e) {
          AppUtils.handleStateError(this, ref, state, e, e.toString());
        },
        minZoom: minZoom,
        maxZoom: maxZoom,
      );
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    } finally {
      await _stylePackSubscription?.cancel();
      await _tileRegionSubscription?.cancel();
    }
  }

  Future<void> deleteRegion(String regionId) async {
    if (!mounted) {
      return;
    }
    updateState(state.copyWith(isLoading: true));
    try {
      await _repository.removeTileRegion(regionId);
      await loadRegions();
      if (!mounted) {
        return;
      }
      updateState(state.copyWith(isLoading: false));
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

  Future<void> clearAllTiles() async {
    try {
      await _repository.clearOldTiles();
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

  Future<void> moveToCurrentLocation(MapboxMap map) async {
    if (!mounted) {
      return;
    }
    updateState(state.copyWith(isLocationLoading: true));
    try {
      final permission = await PermissionService.requestLocationPermissions();
      if (permission == geo.LocationPermission.deniedForever) {
        updateState(
          state.copyWith(
            isLocationLoading: false,
            message:
                'Location permissions permanently denied, please enable in settings.',
          ),
        );
        return;
      }

      if (permission == geo.LocationPermission.denied) {
        updateState(
          state.copyWith(
            isLocationLoading: false,
            message: 'Location permissions denied, using default location.',
          ),
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
      // Added on Exception here
      // Do nothing. Use default location.
      if (kDebugMode) {
        print('Error getting current location: $e, StackTrace: $stackTrace');
      }
      updateState(
        state.copyWith(
          isLocationLoading: false,
          message: 'Error getting current location, using default location.',
        ),
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
        updateState(state.copyWith(isLocationLoading: false));
      }
    }
  }

  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
      return await _repository.getRegionSize(bounds);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error getting region size from viewmodel: $e');
      }
      throw OfflineMapViewModelException('Error getting region size', e);
    }
  }

  @override
  void dispose() {
    _stylePackSubscription?.cancel();
    _tileRegionSubscription?.cancel();
    super.dispose();
  }
}
