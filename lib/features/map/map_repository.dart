// lib/features/map/map_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/shared/models/map_marker.dart';

class MapRepository {
  MapRepository(this._network, this._storage);
  final NetworkService _network;
  final Storage _storage;
  Future<List<MapMarker>> getMarkers({bool forceRefresh = false}) async {
    final lastUpdate = await _storage.getInt(AppConstants.markersKey);
    if (!forceRefresh) {
      if (lastUpdate != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = now - lastUpdate;
        if (diff < const Duration(minutes: 10).inMilliseconds) {
          final cached = await _storage.getMarkers();
          if (cached.isNotEmpty) {
            if (kDebugMode) {
              print('Returning cached markers');
            }
            return cached;
          }
        }
      }
    }
    try {
      if (kDebugMode) {
        print('Request: GET ${AppConfig.locationsPath}');
      }
      final response = await _network.get(AppConfig.locationsPath);
      if (kDebugMode) {
        print('Response: ${response.statusCode} ${response.realUri}');
      }
      if (response.statusCode != 200) {
        throw MapRepositoryException(
          AppConstants.networkError,
          response.statusCode,
        );
      }
      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw MapRepositoryException('Invalid response format', responseData);
      }
      final results = responseData['results'] as List<dynamic>;
      final markers = <MapMarker>[];
      var validMarkers = 0;
      for (final json in results) {
        try {
          final marker = _parseMapMarker(json as Map<String, dynamic>);
          if (marker.geometry.coordinates.isNotEmpty) {
            markers.add(marker);
            validMarkers++;
          } else {
            if (kDebugMode) {
              print('Marker with null coordinates, id: ${marker.id}');
            }
          }
        } on Exception catch (e, stackTrace) {
          if (kDebugMode) {
            print('Error parsing marker: $e, StackTrace: $stackTrace');
          }
        }
      }
      if (markers.isNotEmpty) {
        await _storage.saveMarkers(markers);
        if (kDebugMode) {
          print('Returning $validMarkers markers from API');
        }
        return markers;
      } else {
        if (kDebugMode) {
          print('No valid markers available from API');
        }
        return [];
      }
      }
    on DioException catch (e, stackTrace) {
            final cached = await _storage.getMarkers();
      if (cached.isNotEmpty) {
        if (kDebugMode) {
          print('Returning markers from Cache');
        }
         throw MapRepositoryException(
              'Error getting markers from API, loading from cache',
              e,
              stackTrace,
            );
      }
      if (kDebugMode) {
        print('Error getting markers: $e, StackTrace: $stackTrace');
      }
          throw MapRepositoryException(
              'Error getting markers from API',
              e,
              stackTrace,
            );
    }
    on Exception catch (e, stackTrace) {
          final cached = await _storage.getMarkers();
      if (cached.isNotEmpty) {
          if (kDebugMode) {
              print('Returning markers from Cache');
            }
         throw MapRepositoryException(
              'Error getting markers from API, loading from cache',
              e,
              stackTrace,
            );
        }
       if (kDebugMode) {
          print('Error getting markers: $e, StackTrace: $stackTrace');
        }
          throw MapRepositoryException(
            'Error getting markers from API',
            e,
             stackTrace,
            );
      }
  }

  MapMarker _parseMapMarker(Map<String, dynamic> json) {
    final dynamic geometry = json['geometry'];
    if (geometry == null) {
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

    if (geometry is! Map<String, dynamic>) {
      throw ArgumentError(
        'Invalid geometry format, the value was not a object: $geometry',
      );
    }
    return MapMarker(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] ?? '',
      geometry: Geometry.fromJson(geometry),
    );
  }

  Future<void> updateMarker(MapMarker marker) async {
    try {
      await _network.put('/locations/${marker.id}', marker.toJson());
      final markers = await _storage.getMarkers();
      final markersMap = {for (final m in markers) m.id: m};
      markersMap[marker.id] = marker;
      final updatedMarkers = markersMap.values.toList();
      await _storage.saveMarkers(updatedMarkers);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error updating marker: $e, StackTrace: $stackTrace');
      }
      throw MapRepositoryException('Error updating marker', e, stackTrace);
    }
  }
}

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