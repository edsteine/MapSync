// test/features/offline_map/offline_map_repository_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/features/offline_map/offline_map_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTileService extends Mock implements TileService {}

void main() {
  group('offline_map_repository_unit_test', () {
    late OfflineMapRepository offlineMapRepository;
    late MockTileService mockTileService;
    setUp(() {
      mockTileService = MockTileService();
      offlineMapRepository = OfflineMapRepository(mockTileService);
    });

    test('downloadRegion success', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      when(() => mockTileService.downloadTiles(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      await offlineMapRepository.downloadRegion(
        regionName: 'test',
        bounds: bounds,
        onProgress: (progress) {},
        onComplete: () {},
        onError: (e) {},
      );
      verify(() => mockTileService.downloadTiles(any(), any(), any(), any()))
          .called(1);
    });
    test('getDownloadedRegions success', () async {
      final region = TileRegion(
        id: '0,0-1,1',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      when(() => mockTileService.getAllTileRegions())
          .thenAnswer((_) async => [region]);
      final result = await offlineMapRepository.getDownloadedRegions();
      expect(result, [region]);
    });
    test('removeTileRegion success', () async {
      when(() => mockTileService.removeTileRegion(any()))
          .thenAnswer((_) async {});
      await offlineMapRepository.removeTileRegion('test');
      verify(() => mockTileService.removeTileRegion('test')).called(1);
    });
    test('clearOldTiles success', () async {
      when(() => mockTileService.clearOldTiles()).thenAnswer((_) async {});

      await offlineMapRepository.clearOldTiles();
      verify(() => mockTileService.clearOldTiles()).called(1);
    });

    test('getRegionSize', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      final region = TileRegion(
        id: '0,0-1,1',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );
      when(() => mockTileService.getTileRegion(any()))
          .thenAnswer((_) async => region);
      final size = await offlineMapRepository.getRegionSize(bounds);
      expect(size, '10 B');
    });
    test('getRegionSize null', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      when(() => mockTileService.getTileRegion(any()))
          .thenAnswer((_) async => null);
      final size = await offlineMapRepository.getRegionSize(bounds);
      expect(size, '0 B');
    });
  });
}
