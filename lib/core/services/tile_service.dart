// lib/core/services/tile_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

// Custom exception for TileService errors
class TileServiceException implements Exception {
  TileServiceException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  @override
  String toString() =>
      'TileServiceException: $message, $error, stackTrace: $stackTrace';
}

class TileService {
  TileService();
  TileStore? _tileStore;

  Future<void> initialize() async {
    try {
      _tileStore = await TileStore.createDefault();
      _tileStore?.setDiskQuota(null);
      if (kDebugMode) {
        print('TileStore initialized');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing TileStore: $e, StackTrace: $stackTrace');
      }
      throw TileServiceException('Error initializing TileStore', e, stackTrace);
    }
  }

  Future<void> downloadTiles(
    CoordinateBounds bounds,
    int minZoom,
    int maxZoom,
    String styleUri,
  ) async {
    if (kDebugMode) {
      print('Starting downloadTiles');
    }
    if (_tileStore == null) {
      await initialize();
    }

    try {
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      if (kDebugMode) {
        print('Region ID: $regionId');
      }
      
      final tileRegionLoadOptions = TileRegionLoadOptions(
        // geometry: Point(coordinates: Position(-80.1263, 25.7845)).toJson(),
        geometry: Point(coordinates: Position(34.020882, -6.832477)).toJson(),
        // geometry: Point(coordinates: Position( -6.832477,34.020882)).toJson(),
        
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
      if (kDebugMode) {
        print('Loading tile region');
      }
      await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
          if (kDebugMode) {
            print('TileService progress callback called');
            print('Completed resources: ${progress.completedResourceCount}');
            print('Loaded resources: ${progress.loadedResourceCount}');
            print('Errored resources: ${progress.erroredResourceCount}');
          }
        },
      );
      if (kDebugMode) {
        print('Tile region loaded');
      }
      final tileRegion = await getTileRegion(regionId);
      if (kDebugMode) {
        print('Tile Region Completed Size: ${tileRegion?.completedResourceSize}');
        print('Tile Region Loaded Size: ${tileRegion?.completedResourceCount}');
        print('Tile Region Errored Count: ${tileRegion?.completedResourceSize}');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error downloading tiles: $e, StackTrace: $stackTrace');
      }
      throw TileServiceException('Error downloading tiles', e, stackTrace);
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
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error clearing old tiles: $e, StackTrace: $stackTrace');
      }
      throw TileServiceException('Error clearing old tiles', e, stackTrace);
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
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error removing tile region $regionId: $e, StackTrace: $stackTrace',
        );
      }
      throw TileServiceException(
        'Error removing tile region $regionId',
        e,
        stackTrace,
      );
    }
  }

  Future<TileRegion?> getTileRegion(String regionId) async {
     if (_tileStore == null) {
      await initialize();
    }
    try {
      final regions = await _tileStore!.allTileRegions();
      return regions.firstWhere((region) => region.id == regionId);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error getting tile region $regionId: $e, StackTrace: $stackTrace',
        );
      }
      throw TileServiceException(
        'Error getting tile region $regionId',
        e,
        stackTrace,
      );
    }
  }

  Future<List<TileRegion>> getAllTileRegions() async {
     if (_tileStore == null) {
      await initialize();
    }
    try {
      return await _tileStore!.allTileRegions();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting all tile regions: $e, StackTrace: $stackTrace');
      }
      throw TileServiceException(
        'Error getting all tile regions',
        e,
        stackTrace,
      );
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
    } on Exception catch (e) {
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

final tileServiceProvider = Provider<TileService>((ref) => TileService());