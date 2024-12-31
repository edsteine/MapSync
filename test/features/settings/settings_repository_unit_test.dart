// test/features/settings/settings_repository_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/cache_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/features/settings/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheService extends Mock implements CacheService {}

class MockTileService extends Mock implements TileService {}

void main() {
  group('settings_repository_unit_test', () {
    late SettingsRepository settingsRepository;
    late MockCacheService mockCacheService;
    late MockTileService mockTileService;

    setUp(() {
      mockCacheService = MockCacheService();
      mockTileService = MockTileService();
      settingsRepository =
          SettingsRepository(mockCacheService, mockTileService);
    });

    test('clearCache success', () async {
      when(() => mockCacheService.clearCache()).thenAnswer((_) async {});

      await settingsRepository.clearCache();
      verify(() => mockCacheService.clearCache()).called(1);
    });
    test('getDownloadedRegions success', () async {
      final region = TileRegion(
        id: '0,0-1,1',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      when(() => mockTileService.tileStore?.allTileRegions())
          .thenAnswer((_) async => [region]);
      final result = await settingsRepository.getDownloadedRegions();
      expect(result, ['test']);
    });
    test('getDownloadedRegions no regions', () async {
      when(() => mockTileService.tileStore?.allTileRegions())
          .thenAnswer((_) async => null);

      final result = await settingsRepository.getDownloadedRegions();
      expect(result, []);
    });
    test('deleteRegion success', () async {
      when(() => mockTileService.removeTileRegion(any()))
          .thenAnswer((_) async {});

      await settingsRepository.deleteRegion('test');
      verify(() => mockTileService.removeTileRegion(any())).called(1);
    });
  });
}
