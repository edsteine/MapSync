// test/core/services/storage_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/shared/models/map_marker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBox<T> extends Mock implements Box<T> {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('storage_service_unit_test', () {
    late Storage storage;
    late MockBox<MapMarker> mockMarkerBox;
    late MockSharedPreferences mockPrefs;
    setUp(() async {
      mockMarkerBox = MockBox<MapMarker>();
      mockPrefs = MockSharedPreferences();
      // Register mock Hive and SharedPreferences
      registerFallbackValue(
        MapMarker(
          id: 'test',
          title: 'test',
          description: 'test',
          geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
        ),
      );

      // when(() => Hive.openBox<MapMarker>(any())).thenAnswer((_) async => mockMarkerBox);
      when(SharedPreferences.getInstance).thenAnswer((_) async => mockPrefs);

      storage = await Storage.init();
    });
    test('saveMarkers success', () async {
      final markers = [
        MapMarker(
          id: '1',
          title: 'test1',
          description: 'test1',
          geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
        ),
        MapMarker(
          id: '2',
          title: 'test2',
          description: 'test2',
          geometry: Geometry(type: GeometryType.point, coordinates: [1.0, 1.0]),
        ),
      ];
      when(() => mockMarkerBox.clear()).thenAnswer((_) async => null);
      when(() => mockMarkerBox.putAll(any())).thenAnswer((_) async {});
      when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
      await storage.saveMarkers(markers);

      verify(() => mockMarkerBox.clear()).called(1);
      verify(() => mockMarkerBox.putAll(any())).called(1);
      verify(() => mockPrefs.setInt(any(), any())).called(1);
    });
    test('getMarkers success', () async {
      final markers = [
        MapMarker(
          id: '1',
          title: 'test1',
          description: 'test1',
          geometry: Geometry(type: GeometryType.point, coordinates: [0.0, 0.0]),
        ),
        MapMarker(
          id: '2',
          title: 'test2',
          description: 'test2',
          geometry: Geometry(type: GeometryType.point, coordinates: [1.0, 1.0]),
        ),
      ];
      when(() => mockMarkerBox.values).thenReturn(markers);

      final result = await storage.getMarkers();
      expect(result, markers);
    });
    test('saveInt success', () async {
      when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
      await storage.saveInt('test', 1);

      verify(() => mockPrefs.setInt('test', 1)).called(1);
    });
    test('getInt success', () async {
      when(() => mockPrefs.getInt(any())).thenAnswer((_) async => 1);
      final result = await storage.getInt('test');
      expect(result, 1);
    });
    test('saveString success', () async {
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);
      await storage.saveString('test', 'test');

      verify(() => mockPrefs.setString('test', 'test')).called(1);
    });
    test('getString success', () async {
      when(() => mockPrefs.getString(any())).thenAnswer((_) async => 'test');
      final result = await storage.getString('test');
      expect(result, 'test');
    });
    test('saveBool success', () async {
      when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
      await storage.saveBool('test', value: true);

      verify(() => mockPrefs.setBool('test', true)).called(1);
    });
    test('getBool success', () async {
      when(() => mockPrefs.getBool(any())).thenAnswer((_) async => true);
      final result = await storage.getBool('test');
      expect(result, true);
    });
    test('clearAll success', () async {
      when(() => mockMarkerBox.clear()).thenAnswer((_) async => null);
      when(() => mockPrefs.clear()).thenAnswer((_) async => true);
      await storage.clearAll();
      verify(() => mockMarkerBox.clear()).called(1);
      verify(() => mockPrefs.clear()).called(1);
    });
  });
}
