// lib/features/settings/settings_repository.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/cache_service.dart';
import 'package:mobile/core/services/tile_service.dart';

class SettingsRepository {
  SettingsRepository(this._cacheManager, this._tileManagerService);
  final CacheService _cacheManager;
  final TileService _tileManagerService;

  Future<void> clearCache() async {
    if (kDebugMode) {
      print('Clearing Cache from Settings Repo');
    }
    await _cacheManager.clearCache();
  }

  Future<List<String>> getDownloadedRegions() async {
    if (kDebugMode) {
      print('Getting Downloaded regions from settings repo');
    }
    final regionsFuture = _tileManagerService.tileStore?.allTileRegions();

    if (regionsFuture == null) {
      if (kDebugMode) {
        print('No downloaded regions');
      }
      return [];
    }
    final regions = await regionsFuture;
    if (kDebugMode) {
      print('Downloaded regions: ${regions.map((e) => e.id).toList()}');
    }
    return regions.map((e) => e.id).toList();
  }

  Future<void> deleteRegion(String regionId) async {
    if (kDebugMode) {
      print('Deleting region from Settings repo: $regionId');
    }
    await _tileManagerService.removeTileRegion(regionId);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(cacheManagerProvider),
    ref.watch(tileManagerServiceProvider),
  ),
);
