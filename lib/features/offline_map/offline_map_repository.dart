// lib/features/offline_map/offline_map_repository.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_utils.dart';

class OfflineMapRepository {
  OfflineMapRepository(this._tileService);
  final TileService _tileService;

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
      await _tileService.downloadTiles(
        bounds,
        minZoom ?? 10,
        maxZoom ?? 15,
        'mapbox://styles/mapbox/streets-v12',
      );
      onComplete();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error downloading region from repo $regionName: $e, StackTrace: $stackTrace',
        );
      }
      onError(e);
    }
  }

  Future<List<TileRegion>> getDownloadedRegions() async {
    try {
      return await _tileService.getAllTileRegions();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error getting all tile regions from repo: $e, StackTrace: $stackTrace',
        );
      }
      throw Exception(
        'Error getting all tile regions: $e, StackTrace: $stackTrace',
      );
    }
  }

  Future<void> removeTileRegion(String regionId) async {
    try {
      await _tileService.removeTileRegion(regionId);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error deleting tile region $regionId from repo: $e, StackTrace: $stackTrace',
        );
      }
      throw Exception(
        'Error deleting tile region $regionId: $e, StackTrace: $stackTrace',
      );
    }
  }

  Future<void> clearOldTiles() async {
    try {
      await _tileService.clearOldTiles();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clear all tiles from repo: $e, StackTrace: $stackTrace');
      }
      throw Exception('Error clear all tiles: $e, StackTrace: $stackTrace');
    }
  }

  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      final tileRegion = await _tileService.getTileRegion(regionId);
      if (tileRegion == null) {
        return '0 B';
      }
      final sizeBytes = tileRegion.completedResourceSize;

      return AppUtils.formatFileSize(sizeBytes);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error getting region size from repo: $e, StackTrace: $stackTrace',
        );
      }
      throw Exception('Error getting region size: $e, StackTrace: $stackTrace');
    }
  }
}

final offlineMapRepositoryProvider = Provider<OfflineMapRepository>(
  (ref) => OfflineMapRepository(
    ref.watch(tileServiceProvider),
  ),
);
