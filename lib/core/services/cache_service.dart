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
  String toString() => 'CacheServiceException: $message, $error, stackTrace: $stackTrace';
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
    } on Exception catch (e, stackTrace) {
        if (kDebugMode) {
        print('Error clearing temporaries: $e, StackTrace: $stackTrace');
      }
         throw CacheServiceException('Error clearing temporaries', e, stackTrace);
    }

    // clear map data
    if (kDebugMode) {
      print('About to clear Map Data');
    }
    // Remove region and style pack for all tiles
    try {
      await mapService.removeAllTileRegions();
       await tileManagerService.clearOldTiles();
    } on Exception catch (e, stackTrace) {
       if (kDebugMode) {
        print('Error clearing map data: $e, StackTrace: $stackTrace');
      }
          throw CacheServiceException('Error clearing map data', e, stackTrace);
    }

    // Clear application cache (example)
    try {
      await storage.clearAll();
      if (kDebugMode) {
        print('Cache has been cleared');
      }
    } on Exception catch (e, stackTrace) {
       if (kDebugMode) {
        print('Error clearing storage: $e, StackTrace: $stackTrace');
      }
      throw CacheServiceException('Error clearing storage', e, stackTrace);
    }
  }
}

final cacheManagerProvider = Provider<CacheService>(
  (ref) => CacheService(
    ref.watch(storageProvider).when(
          data: (data) => data,
          error: (error, stack) => throw CacheServiceException('Storage Error: $error', error, stack),
          loading: Storage.new,
        ),
    ref.watch(mapServiceProvider),
    ref.watch(tileServiceProvider),
  ),
);