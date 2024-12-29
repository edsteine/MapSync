import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/performance/app_resource_optimizer.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_constants.dart';

// Custom Exception for CacheService errors
class CacheServiceException implements Exception {
  CacheServiceException(this.message);
  final String message;

  @override
  String toString() => 'CacheServiceException: $message';
}

class CacheService {
  CacheService(this.storage, this.mapService, this.tileManagerService);
  final Storage storage;
  final MapService mapService;
  final TileService tileManagerService;

  Future<void> clearCache() async {
    if (kDebugMode) {
      print('clearCache is being called');
    }

    // Clear temporary files first, before clear map data
    try {
      await AppResourceOptimizer.clearTempFiles();
    } on Exception catch (e) {
        if (kDebugMode) {
        print('Error clearing temporaries: $e');
      }
       throw CacheServiceException('Error clearing temporaries: $e');
    }

    // clear map data
    if (kDebugMode) {
      print('About to clear Map Data');
    }
    // Remove region and style pack for all tiles
    try {
      final regions = await (tileManagerService.tileStore?.allTileRegions() ??
          Future.value([]));

      for (final TileRegion region in regions) {
        await mapService.removeTileRegionAndStylePack(
          region.id,
          AppConstants.mapboxStreets,
        );
      }
      await tileManagerService.clearOldTiles();
    } on Exception catch (e) {
       if (kDebugMode) {
        print('Error clearing map data: $e');
      }
       throw CacheServiceException('Error clearing map data: $e');
    }

    // Clear application cache (example)
    try {
      await storage.clearAll();
      if (kDebugMode) {
        print('Cache has been cleared');
      }
    } on Exception catch (e) {
       if (kDebugMode) {
        print('Error clearing storage: $e');
      }
      throw CacheServiceException('Error clearing storage: $e');
    }
  }
}

final cacheManagerProvider = Provider<CacheService>(
  (ref) => CacheService(
    ref.watch(storageProvider2).when(
          data: (data) => data,
          error: (error, stack) => throw CacheServiceException('Storage Error: $error'),
          loading: Storage.new,
        ),
    ref.watch(mapServiceProvider),
    ref.watch(tileManagerServiceProvider),
  ),
);