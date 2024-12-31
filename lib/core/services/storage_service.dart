///
/// File: lib/core/services/storage_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages data storage using Hive for map markers and SharedPreferences for other settings.
/// Updates: Initial setup with methods to save, retrieve, and clear map markers, integers, strings, and booleans, and added comments
/// Used Libraries: flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, hive_flutter/hive_flutter.dart, mobile/core/utils/app_constants.dart, mobile/shared/models/map_marker.dart, shared_preferences/shared_preferences.dart
///
library;
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

/// Storage class that handles data storage for application
class Storage {
    /// Constructor for the storage class
  Storage();
    /// Future box for storing Map Markers in Hive
  late Future<Box<MapMarker>> _markerBoxFuture;
  /// Shared preferences instance to store simple data
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  /// Initializes the storage by setting up Hive and registering adapters for models.
  static Future<Storage> init() async {
    final storage = Storage();
    try {
       // Initializes hive for flutter storage
      await Hive.initFlutter();
      // Registers the needed adapters for the models
      Hive
        ..registerAdapter(MapMarkerAdapter())
        ..registerAdapter(GeometryAdapter())
        ..registerAdapter(GeometryTypeAdapter()); // Register the new adapter
         // Opens the box for storing the map markers, assigning it to a variable
      storage._markerBoxFuture =
          Hive.openBox<MapMarker>(AppConstants.markersKey);
       // Prints to the console in debug mode when storage is initialized.
      if (kDebugMode) {
        print('Storage Initialized');
      }
      // Returns the initialized storage.
      return storage;
      // Catches any exception that occurs during the storage initialization.
    } on Exception catch (e, stackTrace) {
      // Prints error to the console if there was a failure during initialization
      if (kDebugMode) {
        print('Error initializing storage: $e, StackTrace: $stackTrace');
      }
      // Throws custom exception when initialization fails.
      throw StorageException('Error initializing storage', e, stackTrace);
    }
  }

  // Marker operations

    /// Saves map markers to storage, clearing existing data first.
  Future<void> saveMarkers(List<MapMarker> markers) async {
    try {
       // Gets the map marker box.
      final markerBox = await _markerBoxFuture;
       // Clears the existing data from box.
      await markerBox.clear();
       // Puts all new markers in the box
      await markerBox.putAll(
        Map.fromIterables(
          markers.map((e) => e.id),
          markers,
        ),
      );
         // Gets a shared preference instance
      final prefs = await _prefsFuture;
       // Updates a timestamp for the markers.
      await prefs.setInt(
        AppConstants.markersKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      //Catches any exception that occurs during the save operation
    } on Exception catch (e, stackTrace) {
      //Prints to the console if an error occurs during the saving
      if (kDebugMode) {
        print('Error saving markers: $e, StackTrace: $stackTrace');
      }
       // Throws custom exception when saving markers fails
      throw StorageException('Error saving markers', e, stackTrace);
    }
  }

    /// Retrieves map markers from storage.
  Future<List<MapMarker>> getMarkers() async {
    try {
         // Gets the map marker box.
      final markerBox = await _markerBoxFuture;
      // Returns all the values stored in the box as a list.
      return markerBox.values.toList();
    //Catches any exception that occurs during getting markers.
    } on Exception catch (e, stackTrace) {
      // Prints to console if an error occurs during retrieving markers.
      if (kDebugMode) {
        print('Error getting markers: $e, StackTrace: $stackTrace');
      }
      // Throws custom exception when getting markers fails.
      throw StorageException('Error getting markers', e, stackTrace);
    }
  }

  // Preferences operations

    /// Saves an integer value to shared preferences.
  Future<void> saveInt(String key, int value) async {
    try {
       // Gets shared preference instance.
      final prefs = await _prefsFuture;
      // Set the integer value for a given key
      await prefs.setInt(key, value);
    // Catches any exception that occurs while saving an int value.
    } on Exception catch (e, stackTrace) {
      // Prints to console if an error occurs while saving an integer
      if (kDebugMode) {
        print('Error saving int: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception when saving fails
      throw StorageException('Error saving int', e, stackTrace);
    }
  }

   /// Retrieves an integer value from shared preferences.
  Future<int?> getInt(String key) async {
    try {
        // Gets the shared preference instance
      final prefs = await _prefsFuture;
       // Returns the integer value for a given key
      return prefs.getInt(key);
    // Catches any exception that occurs while getting an int value.
    } on Exception catch (e, stackTrace) {
       // Prints to console if an error occurs while getting an integer
      if (kDebugMode) {
        print('Error getting int: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception when getting int fails
      throw StorageException('Error getting int', e, stackTrace);
    }
  }

   /// Saves a string value to shared preferences.
  Future<void> saveString(String key, String value) async {
    try {
         // Gets shared preference instance
      final prefs = await _prefsFuture;
       // Sets string value for the given key
      await prefs.setString(key, value);
    // Catches any exception that occurs while saving a string
    } on Exception catch (e, stackTrace) {
       // Prints to console if an error occurs while saving a string
      if (kDebugMode) {
        print('Error saving string: $e, StackTrace: $stackTrace');
      }
      // Throws custom exception when saving a string fails.
      throw StorageException('Error saving string', e, stackTrace);
    }
  }

    /// Retrieves a string value from shared preferences.
  Future<String?> getString(String key) async {
    try {
         // Gets shared preference instance.
      final prefs = await _prefsFuture;
         // Returns a string value for the given key
      return prefs.getString(key);
       // Catches any exception that occurs during getting a string.
    } on Exception catch (e, stackTrace) {
       // Prints to console if an error occurs while getting a string.
      if (kDebugMode) {
        print('Error getting string: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception when getting a string fails.
      throw StorageException('Error getting string', e, stackTrace);
    }
  }

    /// Saves a boolean value to shared preferences.
  Future<void> saveBool(String key, {required bool value}) async {
    try {
         // Gets shared preference instance
      final prefs = await _prefsFuture;
       // Saves a boolean value for a given key.
      await prefs.setBool(key, value);
      // Catches any exception that occurs during saving a boolean.
    } on Exception catch (e, stackTrace) {
      // Prints to console if an error occurs while saving a boolean value
      if (kDebugMode) {
        print('Error saving bool: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception when saving a boolean fails.
      throw StorageException('Error saving bool', e, stackTrace);
    }
  }

    /// Retrieves a boolean value from shared preferences.
  Future<bool?> getBool(String key) async {
    try {
        // Gets the shared preference instance.
      final prefs = await _prefsFuture;
        // Returns the boolean value for a given key
      return prefs.getBool(key);
       // Catches any exception that occurs during getting a bool.
    } on Exception catch (e, stackTrace) {
       // Prints to console if an error occurs while getting a boolean.
      if (kDebugMode) {
        print('Error getting bool: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception when getting a boolean fails.
      throw StorageException('Error getting bool', e, stackTrace);
    }
  }

  /// Clears all storage data, both Hive and SharedPreferences.
  Future<void> clearAll() async {
     // Prints to the console in debug mode before cleaning the storage.
    if (kDebugMode) {
      print('Clearing All Storage');
    }
    try {
        // Gets the map marker box
      final markerBox = await _markerBoxFuture;
      // Clears the marker box
      await markerBox.clear();
      // Gets the shared preferences
      final prefs = await _prefsFuture;
       // Clears all data from shared preferences
      await prefs.clear();
        // Prints to the console in debug mode when all the storage is cleared.
      if (kDebugMode) {
        print('All storage cleared');
      }
       //Catches any exception that occurs while clearing all the storage data.
    } on Exception catch (e, stackTrace) {
         // Prints to the console in debug mode when failing to clear the storage
      if (kDebugMode) {
        print('Error clearing storage: $e, StackTrace: $stackTrace');
      }
      //Throws custom exception when failing to clear all storage data.
      throw StorageException('Error clearing storage', e, stackTrace);
    }
  }
}

/// Provider for Storage, providing a single entry point to access storage functionalities.
final storageProvider = FutureProvider<Storage>((ref) async {
  final storage = await Storage.init();
  return storage;
});