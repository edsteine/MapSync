///
/// File: lib/core/services/cache_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages the clearing of application cache, encompassing temporary files, map data, and storage.
/// Updates: Initial setup to clear temporary files, map data and app storage.
/// Used Libraries: flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/performance/app_resource_optimizer.dart, mobile/core/services/map_service.dart, mobile/core/services/storage_service.dart, mobile/core/services/tile_service.dart
///
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/performance/app_resource_optimizer.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';

// Custom Exception for CacheService errors
class CacheServiceException implements Exception {
  CacheServiceException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'CacheServiceException: $message, $error, stackTrace: $stackTrace';
}

/// Manages clearing the application's cache, including temporary files, map data, and storage.
class CacheService {
    /// Constructor for CacheService, it takes `Storage`, `MapService`, and `TileService` as parameters
  CacheService(this.storage, this.mapService, this.tileManagerService);

    /// Storage service for managing preferences and map markers.
  final Storage storage;
    /// Map service for managing map-related operations.
  final MapService mapService;
  /// Tile service for managing offline tiles.
  final TileService tileManagerService;

  /// Clears the application's cache by removing temporary files, map data, and application data.
  Future<void> clearCache() async {
      //Prints to the console when clearCache is called
    if (kDebugMode) {
      print('clearCache is being called');
    }

    // Clear temporary files first, before clear map data
    try {
        // Clear all temp files using resource optimizer
      await AppResourceOptimizer.clearTempFiles();
        //Prints to the console if there was an error deleting temporary files
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing temporaries: $e, StackTrace: $stackTrace');
      }
       // Throws an exception if there was an error during the cleaning process.
      throw CacheServiceException('Error clearing temporaries', e, stackTrace);
    }

    // clear map data
    if (kDebugMode) {
      print('About to clear Map Data');
    }
    // Remove region and style pack for all tiles
    try {
        // Removes all the tile regions and styles from the offline maps.
      await mapService.removeAllTileRegions();
       // Clears the old tiles in the device storage.
      await tileManagerService.clearOldTiles();
        //Prints to the console if there was an error while clearing map data.
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing map data: $e, StackTrace: $stackTrace');
      }
      // Throws an exception if there was an error during the map data cleaning
      throw CacheServiceException('Error clearing map data', e, stackTrace);
    }

    // Clear application cache (example)
    try {
       // Clears all application storage
      await storage.clearAll();
        // Prints to the console when the cache has been successfully cleared.
      if (kDebugMode) {
        print('Cache has been cleared');
      }
      // Catches any exceptions that occurred during clearing the storage
    } on Exception catch (e, stackTrace) {
       // Prints to the console if there was an error while clearing the storage.
      if (kDebugMode) {
        print('Error clearing storage: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception in case of a failure
      throw CacheServiceException('Error clearing storage', e, stackTrace);
    }
  }
}

/// Provider for the CacheService, providing a single entry point to clear the cache.
final cacheManagerProvider = Provider<CacheService>(
  (ref) => CacheService(
    ref.watch(storageProvider).when(
          data: (data) => data,
          error: (error, stack) => throw CacheServiceException(
            'Storage Error: $error',
            error,
            stack,
          ),
          loading: Storage.new,
        ),
    ref.watch(mapServiceProvider),
    ref.watch(tileServiceProvider),
  ),
);