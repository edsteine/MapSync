// test/features/map/map_viewmodel_unit_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/services/map_service.dart';
import 'package:mobile/features/map/map_repository.dart';
import 'package:mobile/features/map/map_viewmodel.dart';
import 'package:mobile/shared/models/map_marker.dart' as map_marker;
import 'package:mocktail/mocktail.dart';

class MockMapRepository extends Mock implements MapRepository {}

class MockMapService extends Mock implements MapService {}

class MockMapboxMap extends Mock implements MapboxMap {}

class MockRef<S> extends Mock implements Ref<S> {}

void main() {
  group('map_viewmodel_unit_test', () {
    late MapViewModel mapViewModel;
    late MockMapRepository mockMapRepository;
    late MockMapService mockMapService;
    late MockMapboxMap mockMapboxMap;
    late MockRef<MapState> mockRef;

    setUp(() {
      mockMapRepository = MockMapRepository();
      mockMapService = MockMapService();
      mockMapboxMap = MockMapboxMap();
      mockRef = MockRef<MapState>();
      mapViewModel = MapViewModel(mockMapRepository, mockMapService, mockRef);
      registerFallbackValue(MapState());

      mapViewModel.setMap(mockMapboxMap);
    });
    test('loadMarkers success', () async {
      when(() => mockMapRepository.getMarkers()).thenAnswer(
        (_) async => Right([
          map_marker.MapMarker(
            id: 'test',
            title: 'test',
            description: 'test',
            geometry: map_marker.Geometry(
              type: map_marker.GeometryType.point,
              coordinates: [0.0, 0.0],
            ),
          ),
        ]),
      );
      await mapViewModel.loadMarkers();
      expect(mapViewModel.state.isLoading, false);
      expect(mapViewModel.state.markers.isNotEmpty, true);
    });
    test('loadMarkers failure', () async {
      when(() => mockMapRepository.getMarkers()).thenAnswer(
        (_) async => Left(MapRepositoryException('test error', 'test')),
      );

      await mapViewModel.loadMarkers();
      expect(mapViewModel.state.isLoading, false);
      expect(mapViewModel.state.error, isNotEmpty);
    });
    test('clearMarkers', () async {
      mapViewModel.clearMarkers();
      expect(mapViewModel.state.markers, isEmpty);
    });
    test('moveToFirstMarker success', () async {
      final markers = [
        map_marker.MapMarker(
          id: 'test',
          title: 'test',
          description: 'test',
          geometry: map_marker.Geometry(
            type: map_marker.GeometryType.point,
            coordinates: [1.0, 1.0],
          ),
        ),
      ];
      when(() => mockMapRepository.getMarkers())
          .thenAnswer((_) async => Right(markers));
      when(() => mockMapboxMap.flyTo(any(), any())).thenAnswer((_) async {});
      await mapViewModel.loadMarkers();
      await mapViewModel.moveToFirstMarker();
      verify(() => mockMapboxMap.flyTo(any(), any())).called(1);
    });
    test('moveToFirstMarker no markers', () async {
      when(() => mockMapRepository.getMarkers())
          .thenAnswer((_) async => const Right([]));
      await mapViewModel.loadMarkers();
      await mapViewModel.moveToFirstMarker();
      verifyNever(() => mockMapboxMap.flyTo(any(), any()));
    });
    test('moveToFirstMarker invalid geometry', () async {
      final markers = [
        map_marker.MapMarker(
          id: 'test',
          title: 'test',
          description: 'test',
          geometry: map_marker.Geometry(
            type: map_marker.GeometryType.lineString,
            coordinates: [1.0, 1.0],
          ),
        ),
      ];
      when(() => mockMapRepository.getMarkers())
          .thenAnswer((_) async => Right(markers));
      await mapViewModel.loadMarkers();
      await mapViewModel.moveToFirstMarker();
      verifyNever(() => mockMapboxMap.flyTo(any(), any()));
    });
  });
}
