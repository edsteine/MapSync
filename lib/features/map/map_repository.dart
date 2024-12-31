///
/// File: lib/features/map/map_repository.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Data layer responsible for fetching map markers from a REST API and managing local storage.
/// Updates: Initial setup with methods to retrieve map markers from API, handle caching, and update markers.
/// Used Libraries: dartz/dartz.dart, dio/dio.dart, flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/config/app_config.dart, mobile/core/services/network_service.dart, mobile/core/services/storage_service.dart, mobile/core/utils/app_constants.dart, mobile/shared/models/map_marker.dart
///
library;
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/shared/models/map_marker.dart';

/// MapRepository class provides data handling methods for map related functionalities.
class MapRepository {
  /// Constructor for the `MapRepository`, it takes instances of `NetworkService` and `Storage`.
  MapRepository(this._network, this._storage);
    /// Network service instance for making api calls.
  final NetworkService _network;
  /// Storage service for managing the local storage.
  final Storage _storage;

    /// Fetches map markers from the API or local storage based on refresh status, returning an Either type.
  Future<Either<MapRepositoryException, List<MapMarker>>> getMarkers({
    bool forceRefresh = false,
  }) async {
    // Gets last update for markers from local storage
    final lastUpdate = await _storage.getInt(AppConstants.markersKey);
    //  Checks if force refresh is false and if there is a last update in local storage.
    if (!forceRefresh) {
      if (lastUpdate != null) {
        // Calculates the time difference
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = now - lastUpdate;
         //Checks if the cache is valid by checking if the last update was within the last 10 minutes.
        if (diff < const Duration(minutes: 10).inMilliseconds) {
             // Gets the markers from local storage if the cache is valid.
          final cached = await _storage.getMarkers();
             // Returns the cached markers if they are not empty.
          if (cached.isNotEmpty) {
             // Prints a message to console if it is returning cached markers in debug mode.
            if (kDebugMode) {
              print('Returning cached markers');
            }
            return Right(cached);
          }
        }
      }
    }
      // Try to retrieve the data from the API
    try {
       // Prints the get request to console in debug mode
      if (kDebugMode) {
        print('Request: GET ${AppConfig.locationsPath}');
      }
      // Makes the request to retrieve the data
      final response = await _network.get(AppConfig.locationsPath);
      // Prints the response status code and the url
      if (kDebugMode) {
        print('Response: ${response.statusCode} ${response.realUri}');
      }
      // Validates the status code
      if (response.statusCode != 200) {
         // Returns an error if the status code is different than 200
        return Left(
          MapRepositoryException(
            'Error getting markers from API - Status code: ${response.statusCode}',
            response.statusCode,
          ),
        );
      }
       // Gets the response data
      final responseData = response.data;
       // Returns an error if the response format is not correct.
      if (responseData == null || responseData is! Map<String, dynamic>) {
        return Left(
          MapRepositoryException('Invalid response format', responseData),
        );
      }
       // Parses the result to a map and a list of map markers
      final results = responseData['results'] as List<dynamic>;
      final markers = <MapMarker>[];
      var validMarkers = 0;
      // Iterates over the results and creates map marker models.
      for (final json in results) {
        try {
          final marker = _parseMapMarker(json as Map<String, dynamic>);
          // Validates that a marker has valid coordinates before adding it to the list
          if (marker.geometry.coordinates.isNotEmpty) {
            markers.add(marker);
            validMarkers++;
            // Logs to the console in debug mode when a marker has null coordinates
          } else {
            if (kDebugMode) {
              print('Marker with null coordinates, id: ${marker.id}');
            }
          }
        // Catches any exception during the parsing of a marker
        } on Exception catch (e, stackTrace) {
           // Prints to console when parsing of a marker fails.
          if (kDebugMode) {
            print('Error parsing marker: $e, StackTrace: $stackTrace');
          }
        }
      }
       // Check if there are valid markers to save
      if (markers.isNotEmpty) {
         // Saves the markers to local storage
        await _storage.saveMarkers(markers);
        // Prints the number of the markers to the console
        if (kDebugMode) {
          print('Returning $validMarkers markers from API');
        }
          // Returns a list of valid markers
        return Right(markers);
          // Returns empty list when there are no valid markers
      } else {
         // Prints a log message to the console if there are no valid markers available from API
        if (kDebugMode) {
          print('No valid markers available from API');
        }
         // Returns an empty array if there are no valid markers from the api.
        return const Right([]);
      }
     // Catches any exception that happens during fetching the markers from api
    } on DioException catch (e, stackTrace) {
        // Prints to console in debug mode that the data is going to be retrieved from cache
      if (kDebugMode) {
        print('Error getting markers from API, loading from cache');
      }
      // Gets the cached markers.
      final cached = await _storage.getMarkers();
      // If cache isn't empty, returns cached markers.
      if (cached.isNotEmpty) {
        return Right(cached);
      }
        // Prints an error message in debug mode
      if (kDebugMode) {
        print('Error getting markers: $e, StackTrace: $stackTrace');
      }
      // Returns an error exception
      return Left(
        MapRepositoryException(
          'Error getting markers from API',
          e,
          stackTrace,
        ),
      );
       // Catches any exception that happens during fetching the markers from api or cache
    } on Exception catch (e, stackTrace) {
      //Prints to console in debug mode that there is an error getting the data, and trying to load from cache
      if (kDebugMode) {
        print('Error getting markers from API, loading from cache');
      }
      // Get's the markers from local storage
      final cached = await _storage.getMarkers();
      // Returns the markers if the cached markers is not empty.
      if (cached.isNotEmpty) {
        return Right(cached);
      }
        // Prints the exception to the console.
      if (kDebugMode) {
        print('Error getting markers: $e, StackTrace: $stackTrace');
      }
      // Returns a generic exception.
      return Left(
        MapRepositoryException(
          'Error getting markers from API',
          e,
          stackTrace,
        ),
      );
    }
  }

  /// Parses a map marker from a JSON object
  MapMarker _parseMapMarker(Map<String, dynamic> json) {
    // Gets the geometry from the json
    final dynamic geometry = json['geometry'];
    // Returns a MapMarker object with default coordinates if geometry is null.
    if (geometry == null) {
        // Prints to console when geometry is null for a marker in debug mode
      if (kDebugMode) {
        print('Geometry is null for marker: ${json['id']}');
      }
      return MapMarker(
        id: json['id'] as String,
        title: json['name'] as String,
        description: json['description'] ?? '',
        geometry: Geometry(
          type: GeometryType.point,
          coordinates: [
            AppConstants.defaultLongitude,
            AppConstants.defaultLatitude,
          ],
        ),
      );
    }

      // Throws an error if the geometry is not a Map.
    if (geometry is! Map<String, dynamic>) {
      throw ArgumentError(
        'Invalid geometry format, the value was not a object: $geometry',
      );
    }
      // Returns a MapMarker from a JSON object.
    return MapMarker(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] ?? '',
      geometry: Geometry.fromJson(geometry),
    );
  }

   /// Updates a map marker using the provided data.
  Future<void> updateMarker(MapMarker marker) async {
    try {
       // Send a put request to update the given marker using it's id.
      await _network.put('/locations/${marker.id}', marker.toJson());
      // Gets the markers from the storage.
      final markers = await _storage.getMarkers();
       // Convert the list of markers into a map using their ids as a key.
      final markersMap = {for (final m in markers) m.id: m};
       // Updates the marker from the map.
      markersMap[marker.id] = marker;
       // Convert the updated markers back to a list
      final updatedMarkers = markersMap.values.toList();
        // Save the markers to the storage.
      await _storage.saveMarkers(updatedMarkers);
        // Catch any exceptions while updating the marker.
    } on Exception catch (e, stackTrace) {
      // Prints an error to the console if it fails to update the marker in debug mode.
      if (kDebugMode) {
        print('Error updating marker: $e, StackTrace: $stackTrace');
      }
      // Throw a custom exception if there is a failure updating the marker.
      throw MapRepositoryException('Error updating marker', e, stackTrace);
    }
  }
}

/// Provider for the MapRepository, provides a single entry point to access map marker functionalities.
final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepository(
    ref.watch(networkServiceProvider),
    ref.watch(storageProvider).when(
          data: (data) => data,
          error: (error, stack) => throw MapRepositoryException(
            'Storage loading error',
            error,
            stack,
          ),
          loading: Storage.new,
        ),
  ),
);

// Custom exception for MapRepository errors
class MapRepositoryException implements Exception {
  MapRepositoryException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  @override
  String toString() =>
      'MapRepositoryException: $message, $error, stackTrace: $stackTrace';
}