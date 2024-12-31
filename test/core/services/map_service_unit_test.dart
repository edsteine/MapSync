// test/core/services/map_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockTileService extends Mock implements TileService {}

void main() {
  group('map_service_unit_test', () {
    late MapService mapService;
    late MockTileService mockTileService;

    setUp(() async {
      mockTileService = MockTileService();

      mapService = MapService(mockTileService);

      await mapService.init();
    });
    test('init success', () async {});
    test('downloadRegion success', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );

      await mapService.downloadRegion(
        regionName: 'test',
        bounds: bounds,
        onProgress: (progress) {},
        onComplete: () {},
        onError: (e) {},
      );
    });

    test('removeTileRegionAndStylePack success', () async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      when(() => mockTileService.getTileRegion(any()))
          .thenAnswer((_) async => region);
      when(() => mockTileService.removeTileRegion(any()))
          .thenAnswer((_) async {});

      await mapService.removeTileRegionAndStylePack('test', 'test');
      verify(() => mockTileService.removeTileRegion(any())).called(1);
    });
    test('removeAllTileRegions success', () async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      when(() => mockTileService.getAllTileRegions())
          .thenAnswer((_) async => [region]);
      when(() => mockTileService.getTileRegion(any()))
          .thenAnswer((_) async => region);

      when(() => mockTileService.removeTileRegion(any()))
          .thenAnswer((_) async {});
      await mapService.removeAllTileRegions();

      verify(() => mockTileService.removeTileRegion(any())).called(1);
    });
  });
}
