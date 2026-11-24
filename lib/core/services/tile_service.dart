///
/// File: lib/core/services/tile_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages offline tile storage and downloads using the Mapbox Maps SDK for Flutter.
/// Updates: Initial setup with tile store initialization, tile download, and region management functions.
/// Used Libraries: dart/io.dart, flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart, path_provider/path_provider.dart
///
library;
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

/// TileService class provides methods for managing offline map tiles using Mapbox SDK.
class TileService {
   /// Constructor for the tile service
  TileService();
  ///  TileStore object for tile storage operations
  TileStore? _tileStore;

    /// Initializes the tile store, creates a default tile store and sets disk quota to null.
  Future<void> initialize() async {
    try {
       // Creates the default tile store
      _tileStore = await TileStore.createDefault();
      // Sets the disk quota to null, allowing unlimited storage.
      _tileStore?.setDiskQuota(null);
      // Prints to console when tile store is successfully initialized.
      if (kDebugMode) {
        print('TileStore initialized');
      }
    } on Exception catch (e, stackTrace) {
       // Prints the error to the console if there was an issue during initialization.
      if (kDebugMode) {
        print('Error initializing TileStore: $e, StackTrace: $stackTrace');
      }
      throw TileServiceException('Error initializing TileStore', e, stackTrace);
    }
  }

    /// Downloads tiles for a specified region, zoom levels, and style URI.
  Future<void> downloadTiles(
    CoordinateBounds bounds,
    int minZoom,
    int maxZoom,
    String styleUri,
  ) async {
    // Prints a message to console when starting the download.
    if (kDebugMode) {
      print('Starting downloadTiles');
    }
    if (_tileStore == null) {
       // Initializes the tile store if it isn't already initialized
      await initialize();
    }

    try {
      // Creates a unique region ID.
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
      // Prints the current region id to the console.
      if (kDebugMode) {
        print('Region ID: $regionId');
      }

       // Configure tile region load options
      final tileRegionLoadOptions = TileRegionLoadOptions(
        // geometry: Point(coordinates: Position(-80.1263, 25.7845)).toJson(),
         // Setting a default geometry for the current region.
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
       // Prints a message to console when tile region is loading.
      if (kDebugMode) {
        print('Loading tile region');
      }
        // Loads the tile region, using a progress callback
      await _tileStore?.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
           // Prints progress to the console.
          if (kDebugMode) {
            print('TileService progress callback called');
            print('Completed resources: ${progress.completedResourceCount}');
            print('Loaded resources: ${progress.loadedResourceCount}');
            print('Errored resources: ${progress.erroredResourceCount}');
          }
        },
      );
       // Prints a message to the console when tile region is loaded.
      if (kDebugMode) {
        print('Tile region loaded');
      }
         // Get the completed tile region
      final tileRegion = await getTileRegion(regionId);
       //Prints the tile region details to the console after the download
      if (kDebugMode) {
        print(
          'Tile Region Completed Size: ${tileRegion?.completedResourceSize}',
        );
        print('Tile Region Loaded Size: ${tileRegion?.completedResourceCount}');
        print(
          'Tile Region Errored Count: ${tileRegion?.completedResourceSize}',
        );
      }
       // Catch any exception that occurs during the download
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error downloading tiles: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception in case of failure.
      throw TileServiceException('Error downloading tiles', e, stackTrace);
    }
  }

    /// Clears old tiles by deleting the tiles directory from the app's document directory.
  Future<void> clearOldTiles() async {
    if (_tileStore == null) {
        // Initializes the tile store if not already initialized.
      await initialize();
    }
      // Prints to console before clearing the old tiles.
    if (kDebugMode) {
      print('Clearing old tiles');
    }
    try {
      // Logic to clear old tile regions
      final dir = await getApplicationDocumentsDirectory();
      final tilesDir = Directory('${dir.path}/tiles');
      if (tilesDir.existsSync()) {
         // Delete all tiles recursively.
        tilesDir.deleteSync(recursive: true);
        // Prints to console when the old tile directory has been deleted.
        if (kDebugMode) {
          print('Old tiles directory deleted');
        }
      } else {
        // Prints to console when there are no old tiles to clear
        if (kDebugMode) {
          print('No old tiles directory found');
        }
      }
      // Catch any exception that occurs during the cleaning
    } on Exception catch (e, stackTrace) {
       // Prints the exception to console if there was an issue while clearing the old tiles.
      if (kDebugMode) {
        print('Error clearing old tiles: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception in case of failure.
      throw TileServiceException('Error clearing old tiles', e, stackTrace);
    }
  }

    /// Removes a specific tile region by its ID.
  Future<void> removeTileRegion(String regionId) async {
    if (_tileStore == null) {
         // Initializes the tile store if not already initialized.
      await initialize();
    }
    try {
       // Prints the current region id to be removed.
      if (kDebugMode) {
        print('Removing tile region: $regionId');
      }
       // Removes the tile region using it's id.
      await _tileStore?.removeRegion(regionId);
    } on Exception catch (e, stackTrace) {
       // Prints to console in case of error.
      if (kDebugMode) {
        print(
          'Error removing tile region $regionId: $e, StackTrace: $stackTrace',
        );
      }
       // Throws a custom exception in case of failure.
      throw TileServiceException(
        'Error removing tile region $regionId',
        e,
        stackTrace,
      );
    }
  }

    /// Retrieves a specific tile region by its ID.
  Future<TileRegion?> getTileRegion(String regionId) async {
    if (_tileStore == null) {
       // Initializes the tile store if not already initialized.
      await initialize();
    }
    try {
       // Gets all the tile regions.
      final regions = await _tileStore!.allTileRegions();
      // Returns the region that matches the given id or null if not exists.
      return regions.firstWhere((region) => region.id == regionId);
    } on Exception catch (e, stackTrace) {
       // Prints to console in case of error.
      if (kDebugMode) {
        print(
          'Error getting tile region $regionId: $e, StackTrace: $stackTrace',
        );
      }
       // Throws a custom exception in case of failure.
      throw TileServiceException(
        'Error getting tile region $regionId',
        e,
        stackTrace,
      );
    }
  }

    /// Retrieves all available tile regions.
  Future<List<TileRegion>> getAllTileRegions() async {
    if (_tileStore == null) {
        // Initializes the tile store if not already initialized.
      await initialize();
    }
    try {
        // Returns all the tile regions
      return await _tileStore!.allTileRegions();
       // Catch any exception that occurs while getting all the tile regions
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error getting all tile regions: $e, StackTrace: $stackTrace');
      }
       // Throws a custom exception in case of failure.
      throw TileServiceException(
        'Error getting all tile regions',
        e,
        stackTrace,
      );
    }
  }

   /// Checks if a region has been downloaded based on its bounds.
  Future<bool> isRegionDownloaded(CoordinateBounds bounds) async {
    if (_tileStore == null) {
      return false;
    }

    try {
      // Creates a unique region ID.
      final regionId =
          '${bounds.southwest.coordinates.lng},${bounds.southwest.coordinates.lat}-${bounds.northeast.coordinates.lng},${bounds.northeast.coordinates.lat}';
       // Prints the regionId to the console in debug mode.
      if (kDebugMode) {
        print('Checking if region is downloaded: $regionId');
      }
      // Get all regions.
      final regions = await _tileStore!.allTileRegions();
       // Checks if any region exists with the same id.
      final isDownloaded = regions.any((region) => region.id == regionId);
       // Prints whether the region is downloaded or not
      if (kDebugMode) {
        print('Region $regionId is downloaded: $isDownloaded');
      }
      return isDownloaded;
     // Catches the exception, if any happens while checking if a region is downloaded
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error checking if region is downloaded: $e');
      }
      return false; // Or handle the error appropriately
    }
  }

    /// Disposes of the tile store.
  void dispose() {
    _tileStore = null;
  }

    /// Public getter to access _tileStore.
  TileStore? get tileStore => _tileStore;
}

///  Provider for the TileService to manage tile storage and downloads.
final tileServiceProvider = Provider<TileService>((ref) => TileService());