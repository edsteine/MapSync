// lib/features/map/map_repository.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/features/map/models/map_marker.dart';

// Custom exception for MapRepository errors
class MapRepositoryException implements Exception {
  MapRepositoryException(this.message);
  final String message;

  @override
  String toString() => 'MapRepositoryException: $message';
}

class MapRepository {
  MapRepository(this._network, this._storage);
  final NetworkService _network;
  final Storage _storage;
  Future<List<MapMarker>> getMarkers({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.getMarkers();
      if (cached.isNotEmpty) {
        return cached;
      }
    }
    try {
      final response = await _network.get(AppConfig.locationsPath);
      final responseData =
          response.data as Map<String, dynamic>;
      final results = responseData['results'] as List<dynamic>;
      final markers = results
          .map((json) => _parseMapMarker(json as Map<String, dynamic>))
          .toList();
      await _storage.saveMarkers(markers);
      return markers;
    } catch (e) {
      if (e is ArgumentError) {
        if (kDebugMode) {
          print('Data validation error: $e');
        }
      }
      final cached = _storage.getMarkers();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  MapMarker _parseMapMarker(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as String;
    final regex = RegExp(r'POINT \(([^ ]+) ([^)]+)\)');
    final match = regex.firstMatch(coordinates);
    if (match == null) {
      throw ArgumentError('Invalid coordinates format: $coordinates');
    }
    final longitude = double.tryParse(match.group(1)!);
    final latitude = double.tryParse(match.group(2)!);
    if (longitude == null || latitude == null) {
      throw ArgumentError(
          'Could not parse latitude and longitude from : $coordinates',);
    }
    return MapMarker(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> updateMarker(MapMarker marker) async {
    try {
      await _network.put('/locations/${marker.id}', marker.toJson());
      final markers = _storage.getMarkers();

      // Convert markers list to a map for faster lookup
      final markersMap = {for (final m in markers) m.id: m};
      // Update the marker in the map
      markersMap[marker.id] = marker;
      // Convert the map back to a list
      final updatedMarkers = markersMap.values.toList();
      await _storage.saveMarkers(updatedMarkers);
    } catch (e) {
      if (kDebugMode) {
         print('Error updating marker: $e');
      }
      throw MapRepositoryException('Error updating marker: $e');
    }
  }
}

final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepository(
    ref.watch(networkServiceProvider),
    ref.watch(storageProvider2).when(
          data: (data) => data,
          error: (error, stack) => throw MapRepositoryException('Storage loading error: $error'),
          loading: Storage.new,
        ),
  ),
);