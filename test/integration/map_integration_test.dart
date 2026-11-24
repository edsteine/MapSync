// test/integration/map_integration_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/features/map/map_repository.dart';
import 'package:mobile/shared/models/map_marker.dart';

void main() {
  group('map_integration_test', () {
    test('map repository can fetch markers', () async {
      final container = ProviderContainer();
      await container.read(storageProvider.future);
      final mapRepository = container.read(mapRepositoryProvider);
      final result = await mapRepository.getMarkers();
      expect(result, isA<Right<MapRepositoryException, List<MapMarker>>>());
      container.dispose();
    });
    test('map service can be initialized', () async {
      final container = ProviderContainer();
      await container.read(storageProvider.future);
      final mapService = container.read(mapServiceProvider);
      expect(mapService, isA<MapService>());
      container.dispose();
    });

    test('tile service can be initialized', () async {
      final container = ProviderContainer();
      final tileService = container.read(tileServiceProvider);
      expect(tileService, isA<TileService>());
      container.dispose();
    });
  });
}
