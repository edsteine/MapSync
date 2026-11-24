// test/features/map/map_repository_unit_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/features/map/map_repository.dart';
import 'package:mobile/shared/models/map_marker.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkService extends Mock implements NetworkService {}

class MockStorage extends Mock implements Storage {}

void main() {
  group('map_repository_unit_test', () {
    late MapRepository mapRepository;
    late MockNetworkService mockNetworkService;
    late MockStorage mockStorage;
    setUp(() {
      mockNetworkService = MockNetworkService();
      mockStorage = MockStorage();
      mapRepository = MapRepository(mockNetworkService, mockStorage);
    });
    test('getMarkers success from api', () async {
      when(() => mockNetworkService.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: {
            'results': [
              {
                'id': 'test',
                'name': 'test',
                'description': 'test',
                'geometry': {
                  'type': 'Point',
                  'coordinates': [0.0, 0.0],
                },
              }
            ],
          },
          statusCode: 200,
        ),
      );
      when(() => mockStorage.getInt(any())).thenAnswer((_) async => null);
      when(() => mockStorage.saveMarkers(any())).thenAnswer((_) async {});
      final result = await mapRepository.getMarkers();
      expect(result.isRight(), true);
    });

    test('getMarkers success from cache', () async {
      final markers = [
        MapMarker(
          id: 'test',
          title: 'test',
          description: 'test',
          geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
        ),
      ];
      when(() => mockStorage.getInt(any()))
          .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
      when(() => mockStorage.getMarkers()).thenAnswer((_) async => markers);

      final result = await mapRepository.getMarkers();
      expect(result.isRight(), true);
      result.fold((l) => null, (r) => expect(r, markers));
    });
    test('getMarkers failure from api, success from cache', () async {
      when(() => mockNetworkService.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );

      final markers = [
        MapMarker(
          id: 'test',
          title: 'test',
          description: 'test',
          geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
        ),
      ];
      when(() => mockStorage.getMarkers()).thenAnswer((_) async => markers);
      final result = await mapRepository.getMarkers();
      expect(result.isRight(), true);
      result.fold((l) => null, (r) => expect(r, markers));
    });
    test('getMarkers failure', () async {
      when(() => mockNetworkService.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );
      when(() => mockStorage.getMarkers()).thenAnswer((_) async => []);

      final result = await mapRepository.getMarkers();

      expect(result.isLeft(), true);
    });
    test('updateMarker success', () async {
      final marker = MapMarker(
        id: 'test',
        title: 'test',
        description: 'test',
        geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
      );
      when(() => mockNetworkService.put(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(), statusCode: 200),
      );
      when(() => mockStorage.getMarkers()).thenAnswer((_) async => [marker]);
      when(() => mockStorage.saveMarkers(any())).thenAnswer((_) async {});

      await mapRepository.updateMarker(marker);
      verify(() => mockNetworkService.put(any(), any())).called(1);
      verify(() => mockStorage.saveMarkers(any())).called(1);
    });
    test('updateMarker failure', () async {
      final marker = MapMarker(
        id: 'test',
        title: 'test',
        description: 'test',
        geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
      );

      when(() => mockNetworkService.put(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(
        () async => mapRepository.updateMarker(marker),
        throwsA(isA<MapRepositoryException>()),
      );
    });
  });
}
