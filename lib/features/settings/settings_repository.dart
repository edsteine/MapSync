///
/// File: lib/features/settings/settings_repository.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Data layer responsible for handling settings-related operations such as clearing the cache and retrieving downloaded regions.
/// Updates: Initial setup with methods to clear cache, get downloaded regions, and delete specific regions.
/// Used Libraries: flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/services/cache_service.dart, mobile/core/services/tile_service.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/cache_service.dart';
import 'package:mobile/core/services/tile_service.dart';

// Custom Exception for Settings repository errors
class SettingsRepositoryException implements Exception {
  SettingsRepositoryException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'SettingsRepositoryException: $message, $error, stackTrace: $stackTrace';
}

/// SettingsRepository class provides data handling methods for settings related functionalities.
class SettingsRepository {
    /// Constructor of the `SettingsRepository` which requires `CacheService` and `TileService`
  SettingsRepository(this._cacheManager, this._tileManagerService);
   /// Cache service instance for managing cache operations.
  final CacheService _cacheManager;
   /// Tile service instance for managing tile storage operations.
  final TileService _tileManagerService;

  /// Clears the application cache using the provided `CacheService`.
  Future<void> clearCache() async {
       // Prints to the console in debug mode before clearing the cache.
    if (kDebugMode) {
      print('Clearing Cache from Settings Repo');
    }
    try {
      // Clears the cache using cache manager
      await _cacheManager.clearCache();
     // Catches any exception and prints in debug mode
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing cache: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception if there was an error during the clearing of the cache.
      throw SettingsRepositoryException('Error clearing cache', e, stackTrace);
    }
  }

    /// Retrieves downloaded regions from the tile manager.
  Future<List<String>> getDownloadedRegions() async {
    // Prints to the console in debug mode before retrieving the downloaded regions.
    if (kDebugMode) {
      print('Getting Downloaded regions from settings repo');
    }
    try {
        //Fetches all the tile regions from the tile manager service
      final regionsFuture = _tileManagerService.tileStore?.allTileRegions();

        //Return an empty list if no regions was found.
      if (regionsFuture == null) {
        if (kDebugMode) {
          print('No downloaded regions');
        }
        return [];
      }
      //Awaits the tile regions and converts them to a list of ids
      final regions = await regionsFuture;
       //Prints the list of downloaded regions to the console.
      if (kDebugMode) {
        print('Downloaded regions: ${regions.map((e) => e.id).toList()}');
      }
      // Returns the list of tile regions ids
      return regions.map((e) => e.id).toList();
      // Catches any exception and prints in debug mode.
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting downloaded regions: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception if there was an error while getting all downloaded regions
      throw SettingsRepositoryException(
        'Error getting downloaded regions',
        e,
        stackTrace,
      );
    }
  }

    /// Deletes a tile region using the tile manager.
  Future<void> deleteRegion(String regionId) async {
       //Prints to the console in debug mode before removing the given tile region.
    if (kDebugMode) {
      print('Deleting region from Settings repo: $regionId');
    }
    try {
       // Removes the given tile region using the tile id.
      await _tileManagerService.removeTileRegion(regionId);
      // Catches any exception and prints in debug mode
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error deleting region: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception if there was an error during deletion
      throw SettingsRepositoryException('Error deleting region', e, stackTrace);
    }
  }
}

/// Provider for the SettingsRepository to manage settings-related data.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(cacheManagerProvider),
    ref.watch(tileServiceProvider),
  ),
);