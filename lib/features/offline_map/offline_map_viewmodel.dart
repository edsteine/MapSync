///
/// File: lib/features/offline_map/offline_map_viewmodel.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages the state and business logic for the offline map screen, including downloading regions, managing tile regions, and handling location services.
/// Updates: Initial setup with methods for loading regions, downloading regions, managing the download progress, removing tile regions, and moving to current location.
/// Used Libraries: dart/async.dart, flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, geolocator/geolocator.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/services/map_service.dart, mobile/core/services/permission_service.dart, mobile/core/utils/app_constants.dart, mobile/core/utils/app_utils.dart, mobile/features/offline_map/offline_map_repository.dart
///
library;
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

/// Represents the state of the offline map view model.
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
  /// Flag to indicate that the data is loading
  final bool isLoading;
  /// List of TileRegion that have been downloaded
  final List<TileRegion> regions;
  /// Error message if any error occurred.
  final String? error;
    /// Flag to represent download status.
  final DownloadStatus downloadStatus;
    /// Loading state for the current location
  final bool isLocationLoading;
   /// Message to show the user after an action has been done or if an error occurred
  final String? message;
    /// Download progress as a value between 0 and 1.
  final double downloadProgress;
   /// Style pack download progress as a value between 0 and 1.
  final double stylePackProgress;

    /// Creates a copy of the current state with optional new values.
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

/// Provider for the OfflineMapViewModel, provides a single entry point to access the offline map functionalities
final offlineMapViewModelProvider =
    StateNotifierProvider.autoDispose<OfflineMapViewModel, OfflineMapState>(
  (ref) => OfflineMapViewModel(
    ref.watch(offlineMapRepositoryProvider),
    ref,
    ref.watch(mapServiceProvider),
  ),
);

/// Manages the state and logic for the offline map screen, handling downloads, location, and region management
class OfflineMapViewModel extends StateNotifier<OfflineMapState> {
  OfflineMapViewModel(this._repository, this.ref, this._mapService)
      : super(OfflineMapState());
   /// Offline map repository instance for fetching, downloading and deleting data
  final OfflineMapRepository _repository;
   /// Riverpod ref to update the state.
  final Ref ref;
  /// Map service instance, used to handle style packs and tile downloads.
  final MapService _mapService;
   /// Subscription object for listening to style pack loading progress.
  StreamSubscription<double>? _stylePackSubscription;
    /// Subscription object for listening to tile region download progress.
  StreamSubscription<double>? _tileRegionSubscription;

    /// Updates the state of the view model
  void updateState(OfflineMapState newState) {
    state = newState;
  }

    /// Loads downloaded regions and updates the state, sets loading to true and updates when completed
  Future<void> loadRegions() async {
      // returns if the state is not mounted.
    if (!mounted) {
      return;
    }
    // Updates the state to loading.
    updateState(state.copyWith(isLoading: true));
    try {
      // Gets all downloaded regions using the repository and updates the state accordingly.
      final regions = await _repository.getDownloadedRegions();
      // Returns when the state is not mounted.
      if (!mounted) {
        return;
      }
      // Updates the state with the loaded regions and sets loading to false.
      updateState(state.copyWith(regions: regions, isLoading: false));
       // Catches any exceptions and calls the utility error handler.
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

   /// Downloads a specified map region, showing the progress and updating the state accordingly.
  Future<void> downloadRegion({
    required CoordinateBounds bounds,
    required int minZoom,
    required int maxZoom,
    required void Function(double) onProgress,
    required void Function() onComplete,
  }) async {
       // returns if the state is not mounted.
    if (!mounted) {
      return;
    }
    // Updates the state to downloading state and also sets the progress to zero.
    updateState(
      state.copyWith(
        downloadStatus: DownloadStatus.downloading,
        downloadProgress: 0,
        stylePackProgress: 0,
      ),
    );
       // Subscribes to the style pack progress stream
    _stylePackSubscription = _mapService.stylePackProgress.listen((progress) {
      //Updates the style pack progress when the state is mounted
      if (mounted) {
        updateState(state.copyWith(stylePackProgress: progress));
      }
      // Prints the style pack progress to the console in debug mode
      if (kDebugMode) {
        print('Style pack progress: ${progress * 100}%');
      }
    });
        // Subscribes to the tile region download progress stream.
    _tileRegionSubscription = _mapService.tileRegionProgress.listen((progress) {
       //Updates the tile download progress only if the state is mounted
      if (mounted) {
        updateState(state.copyWith(downloadProgress: progress));
      }
        // Prints the download progress to the console in debug mode
      if (kDebugMode) {
        print('Tile region progress: ${progress * 100}%');
      }
    });
    try {
       // Downloads the region using the repository and callbacks for success and failure
      await _repository.downloadRegion(
        regionName: 'region_${DateTime.now().millisecondsSinceEpoch}',
        bounds: bounds,
        onProgress: (progress) {
          if (kDebugMode) {
            print('Download progress: ${progress * 100}%');
          }
        },
        onComplete: () {
          // Update the state when the download is completed.
          if (mounted) {
            updateState(
              state.copyWith(downloadStatus: DownloadStatus.completed),
            );
            // Loads all the regions after completion.
            loadRegions();
          }
        },
        onError: (e) {
           // Calls a helper function for handling errors.
          AppUtils.handleStateError(this, ref, state, e, e.toString());
        },
        minZoom: minZoom,
        maxZoom: maxZoom,
      );
    // Catches any exceptions during the download process
    } on Exception catch (e) {
       // Calls a helper function to handle errors.
      AppUtils.handleStateError(this, ref, state, e, e.toString());
      // Disposes subscriptions
    } finally {
       // Cancels all of the subscriptions
      await _stylePackSubscription?.cancel();
      await _tileRegionSubscription?.cancel();
    }
  }

    /// Deletes a specified tile region and reloads all regions.
  Future<void> deleteRegion(String regionId) async {
       // Return if the state is not mounted.
    if (!mounted) {
      return;
    }
    // Updates the state to loading
    updateState(state.copyWith(isLoading: true));
    try {
      // Removes a tile region using the repository and loads all regions
      await _repository.removeTileRegion(regionId);
      await loadRegions();
      // Returns if the state is not mounted.
      if (!mounted) {
        return;
      }
      //Updates the state to stop loading
      updateState(state.copyWith(isLoading: false));
      // Catch any exception that occurs while deleting the tile region.
    } on Exception catch (e) {
       // Calls a helper function to handle errors.
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

    /// Clears all locally stored tiles.
  Future<void> clearAllTiles() async {
    try {
      // Clear all the locally stored tiles
      await _repository.clearOldTiles();
     // Handles exceptions by calling the error handler
    } on Exception catch (e) {
      AppUtils.handleStateError(this, ref, state, e, e.toString());
    }
  }

   /// Moves the map camera to the current device location
  Future<void> moveToCurrentLocation(MapboxMap map) async {
    // Returns if the state is not mounted.
    if (!mounted) {
      return;
    }
    // updates the state to is location loading
    updateState(state.copyWith(isLocationLoading: true));
    try {
      // Requests location permissions from the user.
      final permission = await PermissionService.requestLocationPermissions();
     // Handles the case when the user has permanently denied the permissions.
      if (permission == geo.LocationPermission.deniedForever) {
         // Updates the state and shows message to the user
        updateState(
          state.copyWith(
            isLocationLoading: false,
            message:
                'Location permissions permanently denied, please enable in settings.',
          ),
        );
        return;
      }
      // Handles the case when the user denies the permission and sets the default location on the map.
      if (permission == geo.LocationPermission.denied) {
           // Updates the state and shows message to the user
        updateState(
          state.copyWith(
            isLocationLoading: false,
            message: 'Location permissions denied, using default location.',
          ),
        );
        // Moves the map to the default location
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
       // Gets current position from the geolocator plugin.
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      // Moves the map to the user's current location
      await map.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: AppConstants.defaultZoom,
        ),
        MapAnimationOptions(duration: 200),
      );
       // Catches any exception that occurs while getting current location.
    } on Exception catch (e, stackTrace) {
       // Logs any error while getting the user's current location in debug mode
      if (kDebugMode) {
        print('Error getting current location: $e, StackTrace: $stackTrace');
      }
      // Updates the state and shows a message to the user.
      updateState(
        state.copyWith(
          isLocationLoading: false,
          message: 'Error getting current location, using default location.',
        ),
      );
        // Moves the map to default location if error getting location.
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
     // Runs this block after the try and catch block regardless.
    } finally {
        // Updates the state to stop loading.
      if (mounted) {
        updateState(state.copyWith(isLocationLoading: false));
      }
    }
  }

   /// Retrieves the size of a specified region
  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
       // Gets region size using the repository
      return await _repository.getRegionSize(bounds);
      // Catches any exception that occurred during getting region size.
    } on Exception catch (e) {
       // Prints to console if there is an error when getting the region size.
      if (kDebugMode) {
        print('Error getting region size from viewmodel: $e');
      }
       // Throws an exception for errors during getting the region size
      throw OfflineMapViewModelException('Error getting region size', e);
    }
  }

  @override
  void dispose() {
    // Cancels all of the stream subscriptions before disposing the view model.
    _stylePackSubscription?.cancel();
    _tileRegionSubscription?.cancel();
    super.dispose();
  }
}