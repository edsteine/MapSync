// lib/core/services/tile_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

// Custom exception for TileService errors
class TileServiceException implements Exception {
  TileServiceException(this.message);
  final String message;

  @override
  String toString() => 'TileServiceException: $message';
}

class TileService {
  TileService();
  TileStore? _tileStore;

  Future<void> initialize() async {
    try {
      _tileStore = await TileStore.createDefault();
      _tileStore?.setDiskQuota(null);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error initializing TileStore: $e');
      }
      throw TileServiceException('Error initializing TileStore: $e');
    }
  }

  Future<void> downloadTiles(
    CoordinateBounds bounds,
    int minZoom,
    int maxZoom,
    String styleUri,
  ) async {
    if (_tileStore == null) {
      await initialize();
    }

    try {
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';

      final tileRegionLoadOptions = TileRegionLoadOptions(
        // geometry: bounds.toJson(),
        descriptorsOptions: [
          TilesetDescriptorOptions(
            styleURI: styleUri,
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
        ],
        acceptExpired: true,
        networkRestriction: NetworkRestriction.NONE,
      );
      await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {},
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error downloading tiles: $e');
      }
      throw TileServiceException('Error downloading tiles: $e');
    }
  }

  Future<void> clearOldTiles() async {
    if (_tileStore == null) {
      await initialize();
    }
    if (kDebugMode) {
      print('Clearing old tiles');
    }
    try {
      // Logic to clear old tile regions
      final dir = await getApplicationDocumentsDirectory();
      final tilesDir = Directory('${dir.path}/tiles');
      if (tilesDir.existsSync()) {
        tilesDir.deleteSync(recursive: true);
        if (kDebugMode) {
          print('Old tiles directory deleted');
        }
      } else {
        if (kDebugMode) {
          print('No old tiles directory found');
        }
      }
    } on Exception catch (e) {
       if (kDebugMode) {
         print('Error clearing old tiles: $e');
       }
        throw TileServiceException('Error clearing old tiles: $e');
    }
  }

  Future<void> removeTileRegion(String regionId) async {
    if (_tileStore == null) {
      await initialize();
    }
    try {
      if (kDebugMode) {
        print('Removing tile region: $regionId');
      }
      await _tileStore?.removeRegion(regionId);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error removing tile region $regionId: $e');
      }
      throw TileServiceException('Error removing tile region $regionId: $e');
    }
  }

  Future<TileRegion?> getTileRegion(String regionId) async {
    if (_tileStore == null) {
      await initialize();
    }
    try {
      final regions = await _tileStore!.allTileRegions();
      return regions.firstWhere((region) => region.id == regionId);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error getting tile region $regionId: $e');
      }
      throw TileServiceException('Error getting tile region $regionId: $e');
    }
  }

  Future<bool> isRegionDownloaded(CoordinateBounds bounds) async {
    if (_tileStore == null) {
      return false;
    }

    try {
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      if (kDebugMode) {
        print('Checking if region is downloaded: $regionId');
      }
      final regions = await _tileStore!.allTileRegions();
      final isDownloaded = regions.any((region) => region.id == regionId);
      if (kDebugMode) {
        print('Region $regionId is downloaded: $isDownloaded');
      }
      return isDownloaded;
    } on Exception catch (e) { // Changed catch(e) to on Exception catch (e)
      if (kDebugMode) {
        print('Error checking if region is downloaded: $e');
      }
      return false; // Or handle the error appropriately
    }
  }

  void dispose() {
    _tileStore = null;
  }

  // Public getter to access _tileStore
  TileStore? get tileStore => _tileStore;
}

final tileManagerServiceProvider =
    Provider<TileService>((ref) => TileService());