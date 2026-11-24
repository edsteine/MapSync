// test/core/services/tile_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/tile_service.dart';

void main() {
  group('tile_service_unit_test', () {
    late TileService tileService;

    setUp(() async {
      tileService = TileService();
      await tileService.initialize();
    });
    test('initialize success', () async {});
    test('downloadTiles success', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: false,
      );
      await tileService.downloadTiles(bounds, 1, 5, 'test');
    });

    test('removeTileRegion success', () async {
      await tileService.removeTileRegion('test');
    });

    test('getTileRegion success', () async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );
      final result = await tileService.getTileRegion('test');
      expect(result, region);
    });

    test('getAllTileRegions success', () async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      final result = await tileService.getAllTileRegions();
      expect(result, [region]);
    });
    test('isRegionDownloaded true', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: false,
      );

      final region = TileRegion(
        id: '0,0-1,1',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      final result = await tileService.isRegionDownloaded(bounds);
      expect(result, true);
    });
    test('isRegionDownloaded false', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: false,
      );

      final result = await tileService.isRegionDownloaded(bounds);
      expect(result, false);
    });
  });
}
