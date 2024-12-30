// lib/core/services/storage_service.dart
import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/shared/models/map_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom Exception for Storage service errors
class StorageException implements Exception {
  StorageException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'StorageException: $message, $error, stackTrace: $stackTrace';
}

class Storage {
  Storage();
  late Future<Box<MapMarker>> _markerBoxFuture;
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  static Future<Storage> init() async {
    final storage = Storage();
    try {
      await Hive.initFlutter();
      Hive
        ..registerAdapter(MapMarkerAdapter())
        ..registerAdapter(GeometryAdapter())
        ..registerAdapter(GeometryTypeAdapter()); // Register the new adapter
      storage._markerBoxFuture =
          Hive.openBox<MapMarker>(AppConstants.markersKey);
      if (kDebugMode) {
        print('Storage Initialized');
      }
      return storage;
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing storage: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error initializing storage', e, stackTrace);
    }
  }

  // Marker operations
  Future<void> saveMarkers(List<MapMarker> markers) async {
    try {
      final markerBox = await _markerBoxFuture;
      await markerBox.clear();
      await markerBox.putAll(
        Map.fromIterables(
          markers.map((e) => e.id),
          markers,
        ),
      );
      final prefs = await _prefsFuture;
      await prefs.setInt(
        AppConstants.markersKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error saving markers: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error saving markers', e, stackTrace);
    }
  }

  Future<List<MapMarker>> getMarkers() async {
    try {
      final markerBox = await _markerBoxFuture;
      return markerBox.values.toList();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting markers: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error getting markers', e, stackTrace);
    }
  }

  // Preferences operations
  Future<void> saveInt(String key, int value) async {
    try {
      final prefs = await _prefsFuture;
      await prefs.setInt(key, value);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error saving int: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error saving int', e, stackTrace);
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final prefs = await _prefsFuture;
      return prefs.getInt(key);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting int: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error getting int', e, stackTrace);
    }
  }

  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await _prefsFuture;
      await prefs.setString(key, value);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error saving string: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error saving string', e, stackTrace);
    }
  }

  Future<String?> getString(String key) async {
    try {
      final prefs = await _prefsFuture;
      return prefs.getString(key);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting string: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error getting string', e, stackTrace);
    }
  }

  Future<void> saveBool(String key, {required bool value}) async {
    try {
      final prefs = await _prefsFuture;
      await prefs.setBool(key, value);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error saving bool: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error saving bool', e, stackTrace);
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _prefsFuture;
      return prefs.getBool(key);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting bool: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error getting bool', e, stackTrace);
    }
  }

  Future<void> clearAll() async {
    if (kDebugMode) {
      print('Clearing All Storage');
    }
    try {
      final markerBox = await _markerBoxFuture;
      await markerBox.clear();
      final prefs = await _prefsFuture;
      await prefs.clear();
      if (kDebugMode) {
        print('All storage cleared');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing storage: $e, StackTrace: $stackTrace');
      }
      throw StorageException('Error clearing storage', e, stackTrace);
    }
  }
}

final storageProvider = FutureProvider<Storage>((ref) async {
  final storage = await Storage.init();
  return storage;
});
