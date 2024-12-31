///
/// File: lib/features/map/map_viewmodel.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages the state and logic for the map screen, including loading markers, handling location services, and moving the map to the first marker or current location.
/// Updates: Initial setup with loading markers, moving to first marker, clearing markers, and handling location services with current location functionality.
/// Used Libraries: flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, geolocator/geolocator.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/services/map_service.dart, mobile/core/services/permission_service.dart, mobile/core/utils/app_constants.dart, mobile/core/utils/app_utils.dart, mobile/core/utils/context_provider.dart, mobile/features/map/map_repository.dart, mobile/shared/models/map_marker.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';
import 'package:mobile/core/utils/context_provider.dart';
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

/// Represents the state of the map view model
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
  ///  Flag to represent the loading state
  final bool isLoading;
    /// List of map markers to display on the map
  final List<map_marker.MapMarker> markers;
   /// Error message if any error has occurred
  final String? error;
    /// Flag indicating if the app is in offline mode
  final bool isOffline;
   /// Flag indicating if the markers were successfully fetched
  final bool didFetchSuccessfully;
    ///  Loading state for the current location functionality
  final bool isLocationLoading;
    /// Message for feedback to the user, like success or error messages
  final String? message;

    /// Create a copy of the state with updated values.
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

/// Provider for the MapViewModel to manage the state and logic for the map screen.
final mapViewModelProvider = StateNotifierProvider<MapViewModel, MapState>(
  (ref) => MapViewModel(
    ref.watch(mapRepositoryProvider),
    ref.watch(mapServiceProvider),
    ref,
  ),
);

/// MapViewModel manages the state and business logic for the map screen.
class MapViewModel extends StateNotifier<MapState> {
  /// Constructor for `MapViewModel`, it takes an instance of `MapRepository`, `MapService`, and a `Ref`
  MapViewModel(this._repository, this._mapService, this.ref)
      : super(MapState());
   /// Map repository instance for fetching and updating data.
  final MapRepository _repository;
   /// Map service instance for tile downloads and style management
  final MapService _mapService;
    /// Riverpod ref to update the state
  final Ref<MapState> ref;
   /// Mapbox map instance to perform map related operations.
  MapboxMap? _map;
  
    ///  Sets the MapboxMap instance for the view model.
  void setMap(MapboxMap map) {
    _map = map;
    // Initializes map service
    _mapService.init();
  }

    /// Loads the map markers from the API or local storage, handles errors and loading states, using an Either type.
  Future<void> loadMarkers({bool forceRefresh = false}) async {
     // return if the state is not mounted
    if (!mounted) {
      return;
    }
    // Prints a message to the console before getting the markers.
    if (kDebugMode) {
      print(
        'MapViewModel: loadMarkers started with forceRefresh: $forceRefresh',
      );
    }
    // Sets the state to loading.
    state = state.copyWith(isLoading: true);
    try {
       // Fetches the markers from the repository
      final result = await _repository.getMarkers(forceRefresh: forceRefresh);
       // Returns if the state is not mounted
      if (!mounted) {
        return;
      }

      // Handles the Either type (Right(data) or Left(error))
      result.fold((error) {
        // Prints the error message to the console in debug mode.
        if (kDebugMode) {
          print('MapViewModel: MapRepositoryException: $error');
        }
          // Handles the error using the utility class and shows snackbar to the user if the context is available
        if (mounted && ref.read(contextProvider) != null) {
           // Prints to console before calling the app utils helper to handle the errors
          if (kDebugMode) {
            print('MapViewModel: Calling AppUtils.handleStateError');
          }
          AppUtils.handleStateError(
            this,
            ref,
            state,
            error,
            '${AppConstants.unableToLoadMarkersError}: ${error.toString()}',
          );
        }
        // Prints the error to the console in debug mode
        if (kDebugMode) {
          print('MapViewModel: setting error state: ${error.toString()}');
        }
        // Updates the state with an error message and stop loading.
        state = state.copyWith(
          isLoading: false,
          error:
              '${AppConstants.unableToLoadMarkersError}: ${error.toString()}',
        );
        // Handles the markers in the Right of Either type.
      }, (data) {
        // Prints to the console the number of markers when using API
        if (kDebugMode) {
          print('MapViewModel: Loaded markers: ${data.length} from API');
        }
        // Updates the state with the markers, setting the offline status, load status and message.
        state = state.copyWith(
          isLoading: false,
          markers: data,
          isOffline: false,
          didFetchSuccessfully: data.isNotEmpty,
          message: data.isNotEmpty
              ? '${data.length} markers added from a total of ${data.length} results'
              : null,
        );
          // Moves the camera to the first marker in the markers list
        if (data.isNotEmpty) {
          moveToFirstMarker();
        }
      });
        // Catches any exceptions and handles them using the utility function for errors
    } on Exception catch (e) {
        // Prints the exception to the console in debug mode
      if (kDebugMode) {
        print('MapViewModel: Generic Exception: $e');
      }
        // Handles the error using the app utility class.
      if (mounted && ref.read(contextProvider) != null) {
          // Prints to console that it's calling the error helper function.
        if (kDebugMode) {
          print(
            'MapViewModel: Calling AppUtils.handleStateError on Generic Exception',
          );
        }
        AppUtils.handleStateError(
          this,
          ref,
          state,
          e,
          '${AppConstants.unableToLoadMarkersError}: ${e.toString()}',
        );
      }
      // Prints to the console that is setting the error state
      if (kDebugMode) {
        print('MapViewModel: setting error state: ${e.toString()}');
      }
      // Updates the state with an error message
      state = state.copyWith(
        isLoading: false,
        error: '${AppConstants.unableToLoadMarkersError}: ${e.toString()}',
      );
    }
  }

  /// Moves the camera to the first marker in the list, if any exist
  Future<void> moveToFirstMarker() async {
     // return if map is null
    if (_map == null) {
      return;
    }
      // Checks if there is any marker in the list
    if (state.markers.isNotEmpty) {
         // gets the first marker.
      final firstMarker = state.markers.first;
       // Validates that there are coordinates before moving the map camera.
      if (firstMarker.geometry.coordinates.isNotEmpty &&
          firstMarker.geometry.type == map_marker.GeometryType.point) {
        // Moves the map to the first marker
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

   /// Clears the current markers from the state.
  Future<void> clearMarkers() async {
      // Return if state is not mounted
    if (!mounted) {
      return;
    }
    // Sets the markers to empty list
    state = state.copyWith(markers: []);
  }

  /// Moves the map camera to the current device location using the `MapService` or default coordinates when the permission has been denied.
  Future<void> moveToCurrentLocation(MapboxMap map) async {
     // Returns when the state is not mounted.
    if (!mounted) {
      return;
    }
      // Sets isLocationLoading to true.
    state = state.copyWith(isLocationLoading: true);
    try {
       // Requests permission for location from the user
      final permission = await PermissionService.requestLocationPermissions();
       // Handles the case when location permission has been permanently denied
      if (permission == geo.LocationPermission.deniedForever) {
         // Updates the state with a specific message when the location is permanently denied
        state = state.copyWith(
          isLocationLoading: false,
          message:
              'Location permissions permanently denied, please enable in settings.',
        );
        return;
      }
      // Handles the case when the location permissions have been denied by the user.
      if (permission == geo.LocationPermission.denied) {
         // Updates the state to show the message to the user.
        state = state.copyWith(
          isLocationLoading: false,
          message: 'Location permissions denied, using default location.',
        );
        // Moves the map to the default position
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
      // Get's current position with high accuracy using the geolocator plugin.
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      // Moves the map to the user's current location.
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
      // Logs the exception to the console in debug mode.
      if (kDebugMode) {
        print('Error getting current location: $e, StackTrace: $stackTrace');
      }
        // Updates the state with the error message when the current location cannot be obtained.
      state = state.copyWith(
        isLocationLoading: false,
        message: 'Error getting current location, using default location.',
      );
        // Moves the map to the default location if there is an error while getting the user location.
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
       // Finally, update the state to not loading when the operation has finished
    } finally {
      if (mounted) {
        state = state.copyWith(isLocationLoading: false);
      }
    }
  }
}