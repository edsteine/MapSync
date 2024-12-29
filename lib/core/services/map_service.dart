// lib/core/services/map_service.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/map_helpers.dart';

// Custom exception for MapService errors
class MapServiceException implements Exception {
  MapServiceException(this.message);
  final String message;
   @override
  String toString() => 'MapServiceException: $message';
}

class MapService {
  MapService(this._tileManagerService);
  final TileService _tileManagerService;
  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  Stream<double> get downloadProgress => _progressController.stream;

  Future<void> init() async {
    try {
      _offlineManager = await OfflineManager.create();
      _tileStore = await TileStore.createDefault();
      _tileStore?.setDiskQuota(null);
      await NotificationService.init();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Map Service: $e');
      }
      rethrow;
    }
  }

  int calculateTileCount(CoordinateBounds bounds, int minZoom, int maxZoom) {
    final latDiff =
        (bounds.northeast.coordinates.lat - bounds.southwest.coordinates.lat)
            .abs();
    final lngDiff =
        (bounds.northeast.coordinates.lng - bounds.southwest.coordinates.lng)
            .abs();

    var totalTiles = 0;
    for (var z = minZoom; z <= maxZoom; z++) {
      final tilesPerLat = (latDiff * pow(2, z)).ceil();
      final tilesPerLng = (lngDiff * pow(2, z)).ceil();
      totalTiles += tilesPerLat * tilesPerLng;
    }

    return totalTiles;
  }

  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      final tileRegion = await _tileManagerService.getTileRegion(regionId);
      if (tileRegion == null) {
        return '0 B';
      }
      final sizeBytes = tileRegion.completedResourceSize;

      return MapHelpers.formatFileSize(sizeBytes);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error getting region size: $e');
      }
        throw MapServiceException('Error getting region size: $e');

    }
  }

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
      // final maxZoomLevel = maxZoom ?? AppConstants.defaultMaxZoomLevel;
      // final minZoomLevel = minZoom ?? AppConstants.defaultMinZoomLevel;
      const maxZoomLevel = 22;
      const minZoomLevel = 1;
      if (kDebugMode) {
        print('downloadRegion: minZoom=$minZoomLevel, maxZoom=$maxZoomLevel');
      }

      final tileCount = calculateTileCount(bounds, minZoomLevel, maxZoomLevel);
      if (tileCount > 7122999999999250) {
        throw Exception(
            'Selected area would require too many tiles ($tileCount). Please zoom in or select a smaller region.',);
      }
      if (kDebugMode) {
        print('Initializing download for region: $regionName');
      }
      await init();

      if (_tileStore == null) {
        throw Exception('TileStore is null after initialization');
      }

      // Validate coordinates are within valid ranges
      if (bounds.northeast.coordinates.lat > 90 ||
          bounds.northeast.coordinates.lat < -90 ||
          bounds.southwest.coordinates.lat > 90 ||
          bounds.southwest.coordinates.lat < -90 ||
          bounds.northeast.coordinates.lng > 180 ||
          bounds.northeast.coordinates.lng < -180 ||
          bounds.southwest.coordinates.lng > 180 ||
          bounds.southwest.coordinates.lng < -180) {
        throw Exception(
            'Invalid coordinates. Latitude must be between -90 and 90, longitude between -180 and 180',);
      }
      if (kDebugMode) {
        print('Starting download for region $regionName');
        print('Southwest: ${bounds.southwest.coordinates}');
        print('Northeast: ${bounds.northeast.coordinates}');
        print('Zoom levels: min=$minZoomLevel, max=$maxZoomLevel');
      }

      final geometry = {
        'type': 'Polygon',
        'coordinates': [
          [
            [
              bounds.southwest.coordinates.lng,
              bounds.southwest.coordinates.lat,
            ],
            [
              bounds.northeast.coordinates.lng,
              bounds.southwest.coordinates.lat,
            ],
            [
              bounds.northeast.coordinates.lng,
              bounds.northeast.coordinates.lat,
            ],
            [
              bounds.southwest.coordinates.lng,
              bounds.northeast.coordinates.lat,
            ],
            [
              bounds.southwest.coordinates.lng,
              bounds.southwest.coordinates.lat,
            ],
          ]
        ],
      };

      if (kDebugMode) {
        print('Geometry created: $geometry');
      }
      await NotificationService.showProgressNotification(
          title: 'Downloading region', progress: 0, id: 1, indeterminate: true,);

      final tileRegionLoadOptions = TileRegionLoadOptions(
          geometry: geometry,
          descriptorsOptions: [
            TilesetDescriptorOptions(
                styleURI: AppConstants.mapboxStreets,
                minZoom: minZoomLevel,
                maxZoom: maxZoomLevel,),
          ],
          acceptExpired: true,
          networkRestriction: NetworkRestriction.NONE,);

      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      var lastProgress = 0;
      await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
          if (kDebugMode) {
            print('progress.completedResourceCount');
            print(progress.completedResourceCount);
            print(progress.completedResourceSize);
            print(progress.erroredResourceCount);
            print(progress.loadedResourceCount);
            print(progress.loadedResourceSize);
          }
          final totalResources =
              progress.completedResourceCount + progress.erroredResourceCount;
          var currentProgress = 0;
          if (totalResources > 0) {
            currentProgress =
                (progress.completedResourceCount / totalResources).toInt();
            if ((currentProgress - lastProgress).abs() > 0.01) {
              _progressController.add(currentProgress.toDouble());
              lastProgress = currentProgress;
              NotificationService.showProgressNotification(
                title: 'Downloading region',
                progress: (currentProgress * 100).toInt(),
                id: 1,
              );
            }
          }
        },
      );

      if (kDebugMode) {
        print('Download complete for region: $regionName');
      }
      onComplete();
      await NotificationService.cancelNotification(1);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Download failed with error: $e');
        print('Stack trace: $stackTrace');
      }
      onError(e);
      await NotificationService.showNotification(
        title: 'Download failed', body: e.toString(), id: 1,);
      await NotificationService.cancelNotification(1);
      rethrow;
    }
  }

  Future<void> removeTileRegionAndStylePack(
      String tileRegionId, String styleUri,) async {
    try {
      if (kDebugMode) {
        print('Removing tile region and style pack: $tileRegionId, $styleUri');
      }
      await _tileManagerService.removeTileRegion(tileRegionId);
      _tileManagerService.tileStore?.setDiskQuota(0);
      await _offlineManager?.removeStylePack(styleUri);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing tile region and style pack: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _progressController.close();
  }
}

final mapServiceProvider = Provider<MapService>(
  (ref) => MapService(ref.watch(tileManagerServiceProvider)),
);