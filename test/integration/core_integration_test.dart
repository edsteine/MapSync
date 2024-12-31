// test/integration/core_integration_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/cache_service.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';

void main() {
  group('core_integration_test', () {
    test('network, storage, and tile services initialization', () async {
      final container = ProviderContainer();
      await container.read(storageProvider.future);
      final networkService = container.read(networkServiceProvider);
      final tileService = container.read(tileServiceProvider);
      final mapService = container.read(mapServiceProvider);
      final cacheService = container.read(cacheManagerProvider);
      expect(networkService, isA<NetworkService>());
      expect(tileService, isA<TileService>());
      expect(mapService, isA<MapService>());
      expect(cacheService, isA<CacheService>());

      container.dispose();
    });
    test('check app config', () async {
      expect(AppConfig.mapboxAccessToken, isNotEmpty);
    });
  });
}
