// test/core/services/cache_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/cache_service.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

class MockMapService extends Mock implements MapService {}

class MockTileService extends Mock implements TileService {}

void main() {
  group('cache_service_unit_test', () {
    late CacheService cacheService;
    late MockStorage mockStorage;
    late MockMapService mockMapService;
    late MockTileService mockTileService;

    setUp(() {
      mockStorage = MockStorage();
      mockMapService = MockMapService();
      mockTileService = MockTileService();
      cacheService = CacheService(mockStorage, mockMapService, mockTileService);
    });

    test('clearCache success', () async {
      when(() => mockMapService.removeAllTileRegions())
          .thenAnswer((_) async {});
      when(() => mockTileService.clearOldTiles()).thenAnswer((_) async {});
      when(() => mockStorage.clearAll()).thenAnswer((_) async {});

      await cacheService.clearCache();

      verify(() => mockMapService.removeAllTileRegions()).called(1);
      verify(() => mockTileService.clearOldTiles()).called(1);
      verify(() => mockStorage.clearAll()).called(1);
    });
  });
}
