// lib/core/services/map_service.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';

// Custom exception for MapService errors
class MapServiceException implements Exception {
  MapServiceException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  @override
  String toString() =>
      'MapServiceException: $message, $error, stackTrace: $stackTrace';
}

class MapService {
  MapService(this._tileManagerService);
  final TileService _tileManagerService;
  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  final StreamController<double> _stylePackProgress =
      StreamController<double>.broadcast();
    Stream<double> get stylePackProgress => _stylePackProgress.stream;
  final StreamController<double> _tileRegionLoadProgress =
      StreamController<double>.broadcast();
     Stream<double> get tileRegionProgress => _tileRegionLoadProgress.stream;

  Future<void> init() async {
    try {
      _offlineManager = await OfflineManager.create();
      _tileStore = await TileStore.createDefault();
      _tileStore?.setDiskQuota(null);
      await NotificationService.init();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing Map Service: $e, StackTrace: $stackTrace');
      }
      throw MapServiceException(
        'Error initializing Map Service',
        e,
        stackTrace,
      );
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

      return AppUtils.formatFileSize(sizeBytes);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting region size: $e, StackTrace: $stackTrace');
      }
      throw MapServiceException('Error getting region size', e, stackTrace);
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
      // final minZoomLevel = minZoom ?? AppConfig.defaultMinZoomLevel;
      const maxZoomLevel = 22;
      const minZoomLevel = 1;
      if (kDebugMode) {
        print('downloadRegion: minZoom=$minZoomLevel, maxZoom=$maxZoomLevel');
      }

      final tileCount = calculateTileCount(bounds, minZoomLevel, maxZoomLevel);
      if (tileCount > 7122999999999250) {
        throw MapServiceException(
          'Selected area would require too many tiles. Please zoom in or select a smaller region. The selected area would require: $tileCount tiles',
          'Tile count too high',
        );
      }
      if (kDebugMode) {
        print('Initializing download for region: $regionName');
      }
      await init();

      if (_tileStore == null) {
        throw MapServiceException(
          'TileStore is null after initialization',
          'TileStore is null',
        );
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
        throw MapServiceException(
          'Invalid coordinates. Latitude must be between -90 and 90, longitude between -180 and 180',
          'Invalid Coordinates',
        );
      }
      if (kDebugMode) {
        print('Starting download for region $regionName');
        print('Southwest: ${bounds.southwest.coordinates}');
        print('Northeast: ${bounds.northeast.coordinates}');
        print('Zoom levels: min=$minZoomLevel, max=$maxZoomLevel');
      }

       final stylePackLoadOptions = StylePackLoadOptions(
        glyphsRasterizationMode:
            GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
        metadata: {'tag': regionName},
        acceptExpired: true,);
       await _offlineManager?.loadStylePack(AppConstants.mapboxStreets, stylePackLoadOptions,
        (progress) {
              final percentage = progress.completedResourceCount / progress.requiredResourceCount;
                if (!_stylePackProgress.isClosed) {
                  _stylePackProgress.sink.add(percentage);
                }
        }).then((value) {
            _stylePackProgress.sink.add(1);
            _stylePackProgress.sink.close();
         });

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
        title: 'Downloading region',
        progress: 0,
        id: 1,
        indeterminate: true,
      );

      final tileRegionLoadOptions = TileRegionLoadOptions(
        geometry: geometry,
        descriptorsOptions: [
          TilesetDescriptorOptions(
            styleURI: AppConstants.mapboxStreets,
            minZoom: minZoomLevel,
            maxZoom: maxZoomLevel,
          ),
        ],
        acceptExpired: true,
        networkRestriction: NetworkRestriction.NONE,
      );

      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
     
        await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
           final percentage = progress.completedResourceCount / progress.requiredResourceCount;
            if (!_tileRegionLoadProgress.isClosed) {
               _tileRegionLoadProgress.sink.add(percentage);
           }
          if (kDebugMode) {
             print('progress.completedResourceCount');
            print(progress.completedResourceCount);
            print(progress.completedResourceSize);
            print(progress.erroredResourceCount);
            print(progress.loadedResourceCount);
            print(progress.loadedResourceSize);
          }
         
        },
      ).then((value){
           _tileRegionLoadProgress.sink.add(1);
          _tileRegionLoadProgress.sink.close();
      });

      if (kDebugMode) {
        print('Download complete for region: $regionName');
      }
      onComplete();
      await NotificationService.cancelNotification(1);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Download failed with error: $e, StackTrace: $stackTrace');
      }
      onError(e);
      await NotificationService.showNotification(
        title: 'Download failed',
        body: e.toString(),
        id: 1,
      );
      await NotificationService.cancelNotification(1);
      throw MapServiceException('Download failed', e, stackTrace);
    }
  }

  Future<void> removeTileRegionAndStylePack(
    String tileRegionId,
    String styleUri,
  ) async {
    try {
      final tileRegion = await _tileManagerService.getTileRegion(tileRegionId);
      if (tileRegion == null) {
        if (kDebugMode) {
          print(
            'Tile region with id $tileRegionId does not exist, cannot remove style pack.',
          );
        }
        return;
      }
      if (kDebugMode) {
        print('Removing tile region and style pack: $tileRegionId, $styleUri');
      }
      await _tileManagerService.removeTileRegion(tileRegionId);
      _tileManagerService.tileStore?.setDiskQuota(0);
      await _offlineManager?.removeStylePack(styleUri);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          'Error removing tile region and style pack: $e, StackTrace: $stackTrace',
        );
      }
      throw MapServiceException(
        'Error removing tile region and style pack',
        e,
        stackTrace,
      );
    }
  }

  Future<void> removeAllTileRegions() async {
    try {
      final regions = await _tileManagerService.getAllTileRegions();
      for (final region in regions) {
        await removeTileRegionAndStylePack(
          region.id,
          AppConstants.mapboxStreets,
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error removing all tile regions: $e, StackTrace: $stackTrace');
      }
      throw MapServiceException(
        'Error removing all tile regions',
        e,
        stackTrace,
      );
    }
  }

  void dispose() {
    _tileRegionLoadProgress.close();
        _stylePackProgress.close();
  }
}

final mapServiceProvider = Provider<MapService>(
  (ref) => MapService(ref.watch(tileServiceProvider)),
);