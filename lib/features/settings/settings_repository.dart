// lib/features/settings/settings_repository.dart
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

class SettingsRepository {
  SettingsRepository(this._cacheManager, this._tileManagerService);
  final CacheService _cacheManager;
  final TileService _tileManagerService;

  Future<void> clearCache() async {
    if (kDebugMode) {
      print('Clearing Cache from Settings Repo');
    }
    try {
      await _cacheManager.clearCache();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing cache: $e, StackTrace: $stackTrace');
      }
      throw SettingsRepositoryException('Error clearing cache', e, stackTrace);
    }
  }

  Future<List<String>> getDownloadedRegions() async {
    if (kDebugMode) {
      print('Getting Downloaded regions from settings repo');
    }
    try {
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
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting downloaded regions: $e, StackTrace: $stackTrace');
      }
      throw SettingsRepositoryException(
        'Error getting downloaded regions',
        e,
        stackTrace,
      );
    }
  }

  Future<void> deleteRegion(String regionId) async {
    if (kDebugMode) {
      print('Deleting region from Settings repo: $regionId');
    }
    try {
      await _tileManagerService.removeTileRegion(regionId);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error deleting region: $e, StackTrace: $stackTrace');
      }
      throw SettingsRepositoryException('Error deleting region', e, stackTrace);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(cacheManagerProvider),
    ref.watch(tileServiceProvider),
  ),
);
