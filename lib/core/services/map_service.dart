///
/// File: lib/core/services/map_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages map-related operations such as downloading regions, removing style packs, and calculating tile counts.
/// Updates: Initial setup with functionalities for downloading regions, managing styles, and calculating tiles and size. Includes detailed error handling and logging.
/// Used Libraries: dart/async.dart, dart/math.dart, flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, mobile/core/services/notification_service.dart, mobile/core/services/tile_service.dart, mobile/core/utils/app_constants.dart, mobile/core/utils/app_utils.dart
///
library;
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';

// Custom exception for MapService errors, provides a structured way to handle errors within the service.
class MapServiceException implements Exception {
  MapServiceException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  @override
  String toString() =>
      'MapServiceException: $message, $error, stackTrace: $stackTrace';
}

/// MapService class manages map-related operations such as tile downloads, style packs and region management.
class MapService {
  /// Constructor for the Map Service, requires an instance of `TileService`.
  MapService(this._tileManagerService);

  ///  Tile service manager for handling tile storage operations.
  final TileService _tileManagerService;

  /// Tile store object for tile storage operations
  TileStore? _tileStore;

  ///  Offline manager object to manage offline resources like style packs.
  OfflineManager? _offlineManager;

  /// Stream controller for tracking the progress of style pack loading.
  final StreamController<double> _stylePackProgress =
      StreamController<double>.broadcast();

  /// Stream that provides updates on the progress of the style pack loading, making it possible to track it from other places in the app
  Stream<double> get stylePackProgress => _stylePackProgress.stream;

  /// Stream controller for tracking the progress of tile region download.
  final StreamController<double> _tileRegionLoadProgress =
      StreamController<double>.broadcast();

  /// Stream that provides updates on the progress of the tile region loading, making it possible to track it from other places in the app.
  Stream<double> get tileRegionProgress => _tileRegionLoadProgress.stream;

  /// Initializes the offline manager, tile store, and notification services required for map operations.
  Future<void> init() async {
    try {
      // Creates a new OfflineManager instance.
      _offlineManager = await OfflineManager.create();
      // Creates a default TileStore instance and disables the disk quota
      _tileStore = await TileStore.createDefault();
      _tileStore?.setDiskQuota(null);
      // Initializes notification service.
      await NotificationService.init();
       // Catching potential exception in case of failure during the initialization of the map service
    } catch (e, stackTrace) {
      // Logging error to console when debug mode is activated
      if (kDebugMode) {
        print('Error initializing Map Service: $e, StackTrace: $stackTrace');
      }
      // Throw a custom exception for handling initialization failure
      throw MapServiceException(
        'Error initializing Map Service',
        e,
        stackTrace,
      );
    }
  }

  /// Calculates the approximate number of tiles required to cover a given region, based on the zoom levels.
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

  /// Retrieves and formats the size of a downloaded map region, providing human-readable values
  Future<String> getRegionSize(CoordinateBounds bounds) async {
    try {
      // Creates a unique region ID using the southwest and northeast coordinates.
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
          // Fetches the tile region information for a given id using the tileManagerService.
      final tileRegion = await _tileManagerService.getTileRegion(regionId);
      // Returns "0 B" if no tile region is found for given id.
      if (tileRegion == null) {
        return '0 B';
      }
      // Gets the size of the completed resources.
      final sizeBytes = tileRegion.completedResourceSize;

      // Returns the formatted file size, converting from bytes to a human readable format.
      return AppUtils.formatFileSize(sizeBytes);
       // Handles any exception that occurs during the execution.
    } on Exception catch (e, stackTrace) {
      // Logs error details if an exception occurs in debug mode.
      if (kDebugMode) {
        print('Error getting region size: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception to be handled by the caller
      throw MapServiceException('Error getting region size', e, stackTrace);
    }
  }

  /// Downloads a map region with specified bounds, zoom levels and style, and notifies the user about progress and completion.
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
      // Default max and min zoom level
      const maxZoomLevel = 22;
      const minZoomLevel = 1;
      // Logs the zoom level configurations for this region download process.
      if (kDebugMode) {
        print('downloadRegion: minZoom=$minZoomLevel, maxZoom=$maxZoomLevel');
      }

      // Calculates the total number of tiles required for the specified region and zoom levels
      final tileCount = calculateTileCount(bounds, minZoomLevel, maxZoomLevel);
      // Checks if the selected area would require too many tiles to download, throws an exception if exceeded.
      if (tileCount > 7122999999999250) {
        throw MapServiceException(
          'Selected area would require too many tiles. Please zoom in or select a smaller region. The selected area would require: $tileCount tiles',
          'Tile count too high',
        );
      }
       // Logs the start of the download process for the given region name
      if (kDebugMode) {
        print('Initializing download for region: $regionName');
      }
      // Initializes the map service, which prepares the offline manager, tile store, and notifications.
      await init();

      // Checks if the tile store is initialized. If null an exception is thrown.
      if (_tileStore == null) {
        throw MapServiceException(
          'TileStore is null after initialization',
          'TileStore is null',
        );
      }

      // Validate coordinates are within valid ranges, throwing an error if they aren't
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
      // Prints to console the start of the download region, also the coordinates and zoom level
      if (kDebugMode) {
        print('Starting download for region $regionName');
        print('Southwest: ${bounds.southwest.coordinates}');
        print('Northeast: ${bounds.northeast.coordinates}');
        print('Zoom levels: min=$minZoomLevel, max=$maxZoomLevel');
      }

      // Configure style pack load options for offline use
      final stylePackLoadOptions = StylePackLoadOptions(
        glyphsRasterizationMode:
            GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
        metadata: {'tag': regionName},
        acceptExpired: true,
      );
      // Loads the style pack from a specified URI and updates the style pack loading progress.
      await _offlineManager?.loadStylePack(
          AppConstants.mapboxStreets, stylePackLoadOptions, (progress) {
           // Calculates the percentage of the completed style resources
        final percentage =
            progress.completedResourceCount / progress.requiredResourceCount;
             // Sends the current progress to the stream, only if the stream is not closed.
        if (!_stylePackProgress.isClosed) {
          _stylePackProgress.sink.add(percentage);
        }
        // After finishing, it closes the style pack progress stream.
      }).then((value) {
        _stylePackProgress.sink.add(1);
        _stylePackProgress.sink.close();
      });

      //  Creates a geometry object for the selected region
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

      // Logs the created geometry object in debug mode.
      if (kDebugMode) {
        print('Geometry created: $geometry');
      }
      //  Shows the notification to the user that a download has started for the region.
      await NotificationService.showProgressNotification(
        title: 'Downloading region',
        progress: 0,
        id: 1,
        indeterminate: true,
      );

      // Configure tile region load options
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
      // Creates a unique region ID
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      // Starts the process of downloading the tiles of a region, while also updating the progress stream.
      await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
          // Calculates the percentage of the completed tiles.
          final percentage =
              progress.completedResourceCount / progress.requiredResourceCount;
          // Adds the current percentage to the stream, only if the stream is not closed
          if (!_tileRegionLoadProgress.isClosed) {
            _tileRegionLoadProgress.sink.add(percentage);
          }
          // Logs the progress information to the console
          if (kDebugMode) {
            print('progress.completedResourceCount');
            print(progress.completedResourceCount);
            print(progress.completedResourceSize);
            print(progress.erroredResourceCount);
            print(progress.loadedResourceCount);
            print(progress.loadedResourceSize);
          }
        },
      ).then((value) {
        // Adds 1 to the stream for completion and closes the stream.
        _tileRegionLoadProgress.sink.add(1);
        _tileRegionLoadProgress.sink.close();
      });

      // Logs the completion of download to console for a given region.
      if (kDebugMode) {
        print('Download complete for region: $regionName');
      }
      // Executes the callback for onComplete
      onComplete();
      // Removes the notification when the download has completed.
      await NotificationService.cancelNotification(1);
      //Catches any exceptions that happened during the download
    } on Exception catch (e, stackTrace) {
       // Prints to console the exception in debug mode
      if (kDebugMode) {
        print('Download failed with error: $e, StackTrace: $stackTrace');
      }
       // Executes the callback in case of error.
      onError(e);
       // Shows the notification to the user that download has failed.
      await NotificationService.showNotification(
        title: 'Download failed',
        body: e.toString(),
        id: 1,
      );
      // Removes the notification for the download after the error
      await NotificationService.cancelNotification(1);
        // Throws a custom exception to be handled by the caller
      throw MapServiceException('Download failed', e, stackTrace);
    }
  }

    /// Removes a tile region and its associated style pack.
  Future<void> removeTileRegionAndStylePack(
    String tileRegionId,
    String styleUri,
  ) async {
    try {
        // Retrieves the tile region using the tile id.
      final tileRegion = await _tileManagerService.getTileRegion(tileRegionId);
       // Checks if the tile region with this id exists before removing its style pack.
      if (tileRegion == null) {
          // Logs to console if a tile region doesn't exist
        if (kDebugMode) {
          print(
            'Tile region with id $tileRegionId does not exist, cannot remove style pack.',
          );
        }
        return;
      }
      // Prints to console the tile region and style pack being removed.
      if (kDebugMode) {
        print('Removing tile region and style pack: $tileRegionId, $styleUri');
      }
       // Removes the tile region, the tile store disk quota is set to zero and then removes the style pack using it's url
      await _tileManagerService.removeTileRegion(tileRegionId);
       _tileManagerService.tileStore?.setDiskQuota(0);
      await _offlineManager?.removeStylePack(styleUri);
    } catch (e, stackTrace) {
        // Prints to console if there was an error during the removal of tile region and style pack
      if (kDebugMode) {
        print(
          'Error removing tile region and style pack: $e, StackTrace: $stackTrace',
        );
      }
         // Throws a custom exception to be handled by the caller
      throw MapServiceException(
        'Error removing tile region and style pack',
        e,
        stackTrace,
      );
    }
  }

    /// Removes all tile regions by iterating through each region and its associated style pack.
  Future<void> removeAllTileRegions() async {
    try {
      // Get all tile regions
      final regions = await _tileManagerService.getAllTileRegions();
      // Loop over all of the tile regions
      for (final region in regions) {
        // remove the tile region and its style pack
        await removeTileRegionAndStylePack(
          region.id,
          AppConstants.mapboxStreets,
        );
      }
      // Catch any exception that occurred during the removal of tiles.
    } catch (e, stackTrace) {
       // Prints to console if there was an error removing all tile regions.
      if (kDebugMode) {
        print('Error removing all tile regions: $e, StackTrace: $stackTrace');
      }
      // Throws a custom exception to be handled by the caller
      throw MapServiceException(
        'Error removing all tile regions',
        e,
        stackTrace,
      );
    }
  }

  /// Closes the stream controllers used for tracking the download progress.
  void dispose() {
    _tileRegionLoadProgress.close();
    _stylePackProgress.close();
  }
}

/// Provider for the MapService, allowing access to map-related functionalities.
final mapServiceProvider = Provider<MapService>(
  (ref) => MapService(ref.watch(tileServiceProvider)),
);