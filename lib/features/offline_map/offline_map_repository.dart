///
/// File: lib/features/offline_map/offline_map_repository.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Data layer responsible for handling offline map operations, such as downloading regions, managing tile data, and retrieving downloaded regions.
/// Updates: Initial setup with methods to download regions, retrieve downloaded regions, remove tile regions, clear old tiles, and get region size.
/// Used Libraries: flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/services/tile_service.dart, mobile/core/utils/app_utils.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_utils.dart';

/// OfflineMapRepository class provides data handling methods for offline map related functionalities.
class OfflineMapRepository {
  /// Constructor for the `OfflineMapRepository` which requires a `TileService`
  OfflineMapRepository(this._tileService);
  /// Tile service instance for managing offline tiles
  final TileService _tileService;

   /// Downloads the specified map region using the `TileService`.
  Future<void> downloadRegion({
    required String regionName,
    required CoordinateBounds bounds,
    required void Function(double) onProgress,
    required void Function() onComplete,
    required void Function(dynamic) onError,
    int? maxZoom,
    int? minZoom,
  }) async {
    try {
      // Downloads the tiles for a region with the provided parameters using the TileService.
      await _tileService.downloadTiles(
        bounds,
        minZoom ?? 10,
        maxZoom ?? 15,
        'mapbox://styles/mapbox/streets-v12',
      );
      // Triggers the onComplete callback when the download completes
      onComplete();
       // Catches any exception that occurs during download
    } on Exception catch (e, stackTrace) {
        // Prints to console the exception message in debug mode if the download fails.
      if (kDebugMode) {
        print(
          'Error downloading region from repo $regionName: $e, StackTrace: $stackTrace',
        );
      }
      // Triggers the onError callback, passing in the error.
      onError(e);
    }
  }

    /// Retrieves all downloaded tile regions from the `TileService`.
  Future<List<TileRegion>> getDownloadedRegions() async {
    try {
      // Gets all available tile regions from the TileService.
      return await _tileService.getAllTileRegions();
    // Catches any exception that occurs while getting all the tile regions.
    } on Exception catch (e, stackTrace) {
       // Prints to the console the error message in debug mode.
      if (kDebugMode) {
        print(
          'Error getting all tile regions from repo: $e, StackTrace: $stackTrace',
        );
      }
       // Re-throws the exception with additional context.
      throw Exception(
        'Error getting all tile regions: $e, StackTrace: $stackTrace',
      );
    }
  }

   /// Removes a specific tile region by its ID using the `TileService`.
  Future<void> removeTileRegion(String regionId) async {
    try {
      // Removes the tile region using the provided id in the tile service.
      await _tileService.removeTileRegion(regionId);
       // Catches any exception that occurs while removing the tile region.
    } on Exception catch (e, stackTrace) {
         // Prints the error to console when it fails to delete the tile region.
      if (kDebugMode) {
        print(
          'Error deleting tile region $regionId from repo: $e, StackTrace: $stackTrace',
        );
      }
       // Re-throws the exception with additional context.
      throw Exception(
        'Error deleting tile region $regionId: $e, StackTrace: $stackTrace',
      );
    }
  }

    /// Clears all locally stored old tiles using the `TileService`.
  Future<void> clearOldTiles() async {
    try {
        // Clears all the old tiles using tile service
      await _tileService.clearOldTiles();
         // Catches any exception that occurs during clearing old tiles
    } on Exception catch (e, stackTrace) {
        // Prints error to the console when cleaning the tiles fails.
      if (kDebugMode) {
        print('Error clear all tiles from repo: $e, StackTrace: $stackTrace');
      }
       // Re-throws the exception with additional context.
      throw Exception('Error clear all tiles: $e, StackTrace: $stackTrace');
    }
  }

    /// Gets the size of a specified region using its bounds from the `TileService`
  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
      // Creates the region id using the bounds
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      // Get the tile region from the tile service with given region id.
      final tileRegion = await _tileService.getTileRegion(regionId);
       // Returns "0 B" if no tile region is available.
      if (tileRegion == null) {
        return '0 B';
      }
        // Gets the complete resource size of the region.
      final sizeBytes = tileRegion.completedResourceSize;
      // Formats the size to a human readable format and returns it
      return AppUtils.formatFileSize(sizeBytes);
        // Catches any exception that occurs during getting region size
    } on Exception catch (e, stackTrace) {
         // Prints to the console in debug mode when there is an error when getting region size.
      if (kDebugMode) {
        print(
          'Error getting region size from repo: $e, StackTrace: $stackTrace',
        );
      }
      // Re-throws exception when it failed to get the region size.
      throw Exception('Error getting region size: $e, StackTrace: $stackTrace');
    }
  }
}

/// Provider for the OfflineMapRepository, provides a single entry point for the offline map data.
final offlineMapRepositoryProvider = Provider<OfflineMapRepository>(
  (ref) => OfflineMapRepository(
    ref.watch(tileServiceProvider),
  ),
);