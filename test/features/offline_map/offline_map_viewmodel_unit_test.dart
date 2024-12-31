import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/offline_map/offline_map_repository.dart';
import 'package:mobile/features/offline_map/offline_map_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockOfflineMapRepository extends Mock implements OfflineMapRepository {}

class MockMapService extends Mock implements MapService {}

class MockMapboxMap extends Mock implements MapboxMap {}

class MockRef<S> extends Mock implements Ref<S> {}

void main() {
  group('offline_map_viewmodel_unit_test', () {
    late OfflineMapViewModel offlineMapViewModel;
    late MockOfflineMapRepository mockOfflineMapRepository;
    late MockMapService mockMapService;
    late MockMapboxMap mockMapboxMap;
    late MockRef<OfflineMapState> mockRef;

    setUp(() {
      mockOfflineMapRepository = MockOfflineMapRepository();
      mockMapService = MockMapService();
      mockMapboxMap = MockMapboxMap();
      mockRef = MockRef<OfflineMapState>();
      offlineMapViewModel = OfflineMapViewModel(
        mockOfflineMapRepository,
        mockRef,
        mockMapService,
      );
      registerFallbackValue(OfflineMapState());
    });
    test('loadRegions success', () async {
      when(() => mockOfflineMapRepository.getDownloadedRegions()).thenAnswer(
        (_) async => [
          TileRegion(
            id: 'test',
            completedResourceSize: 10,
            completedResourceCount: 10,
            requiredResourceCount: 10,
          ),
        ],
      );
      await offlineMapViewModel.loadRegions();
      expect(offlineMapViewModel.state.isLoading, false);
      expect(offlineMapViewModel.state.regions.isNotEmpty, true);
    });
    test('loadRegions failure', () async {
      when(() => mockOfflineMapRepository.getDownloadedRegions())
          .thenThrow(Exception('test'));
      await offlineMapViewModel.loadRegions();

      expect(offlineMapViewModel.state.isLoading, false);
      expect(offlineMapViewModel.state.error, isNotEmpty);
    });
    test('downloadRegion success', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      when(() => mockMapService.stylePackProgress)
          .thenReturn(const Stream.empty());
      when(() => mockMapService.tileRegionProgress)
          .thenReturn(const Stream.empty());
      when(
        () => mockOfflineMapRepository.downloadRegion(
          regionName: any(named: 'regionName'),
          bounds: any(named: 'bounds'),
          onProgress: any(named: 'onProgress'),
          onComplete: any(named: 'onComplete'),
          onError: any(named: 'onError'),
          minZoom: any(named: 'minZoom'),
          maxZoom: any(named: 'maxZoom'),
        ),
      ).thenAnswer((_) async {});
      await offlineMapViewModel.downloadRegion(
        bounds: bounds,
        minZoom: 1,
        maxZoom: 5,
        onProgress: (progress) {},
        onComplete: () {},
      );
      expect(
        offlineMapViewModel.state.downloadStatus,
        DownloadStatus.completed,
      );
    });
    test('downloadRegion failure', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );

      when(() => mockMapService.stylePackProgress)
          .thenReturn(const Stream.empty());
      when(() => mockMapService.tileRegionProgress)
          .thenReturn(const Stream.empty());
      when(
        () => mockOfflineMapRepository.downloadRegion(
          regionName: any(named: 'regionName'),
          bounds: any(named: 'bounds'),
          onProgress: any(named: 'onProgress'),
          onComplete: any(named: 'onComplete'),
          onError: any(named: 'onError'),
          minZoom: any(named: 'minZoom'),
          maxZoom: any(named: 'maxZoom'),
        ),
      ).thenThrow(Exception('test'));

      await offlineMapViewModel.downloadRegion(
        bounds: bounds,
        minZoom: 1,
        maxZoom: 5,
        onProgress: (progress) {},
        onComplete: () {},
      );
      expect(offlineMapViewModel.state.downloadStatus, DownloadStatus.idle);
      expect(offlineMapViewModel.state.error, isNotEmpty);
    });
    test('deleteRegion success', () async {
      when(() => mockOfflineMapRepository.removeTileRegion(any()))
          .thenAnswer((_) async {});
      when(() => mockOfflineMapRepository.getDownloadedRegions())
          .thenAnswer((_) async => []);
      await offlineMapViewModel.deleteRegion('test');
      expect(offlineMapViewModel.state.isLoading, false);
      verify(() => mockOfflineMapRepository.removeTileRegion(any())).called(1);
    });
    test('deleteRegion failure', () async {
      when(() => mockOfflineMapRepository.removeTileRegion(any()))
          .thenThrow(Exception('test'));
      await offlineMapViewModel.deleteRegion('test');
      expect(offlineMapViewModel.state.isLoading, false);
      expect(offlineMapViewModel.state.error, isNotEmpty);
    });
    test('moveToCurrentLocation success', () async {
      when(() => mockMapboxMap.flyTo(any(), any())).thenAnswer((_) async {});
      await offlineMapViewModel.moveToCurrentLocation(mockMapboxMap);
      expect(offlineMapViewModel.state.isLocationLoading, false);
    });
    test('clearAllTiles success', () async {
      when(() => mockOfflineMapRepository.clearOldTiles())
          .thenAnswer((_) async {});

      await offlineMapViewModel.clearAllTiles();
      verify(() => mockOfflineMapRepository.clearOldTiles()).called(1);
    });
    test('getRegionSize success', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      when(() => mockOfflineMapRepository.getRegionSize(any()))
          .thenAnswer((_) async => '10 B');
      final result = await offlineMapViewModel.getRegionSize(bounds);
      expect(result, '10 B');
    });
    test('getRegionSize failure', () async {
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(1, 1)),
        infiniteBounds: true,
      );
      when(() => mockOfflineMapRepository.getRegionSize(any()))
          .thenThrow(Exception('test'));
      expect(
        () async => offlineMapViewModel.getRegionSize(bounds),
        throwsA(isA<OfflineMapViewModelException>()),
      );
    });
  });
}
