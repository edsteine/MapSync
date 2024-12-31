// test/core/services/permission_service_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mobile/core/services/permission_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

class MockPermission extends Mock implements Permission {}

class MockGeolocator extends Mock implements geo.Geolocator {}

void main() {
  group('permission_service_unit_test', () {
    late MockPermission mockPermission;
    late MockGeolocator mockGeolocator;

    setUp(() {
      mockPermission = MockPermission();
      mockGeolocator = MockGeolocator();
    });
    test('requestNotificationPermissions granted', () async {
      when(() => mockPermission.request())
          .thenAnswer((_) async => PermissionStatus.granted);
      when(() => Permission.notification).thenReturn(mockPermission);

      await PermissionService.requestNotificationPermissions();
      verify(() => mockPermission.request()).called(1);
    });

    test('requestNotificationPermissions denied', () async {
      when(() => mockPermission.request())
          .thenAnswer((_) async => PermissionStatus.denied);
      when(() => Permission.notification).thenReturn(mockPermission);

      await PermissionService.requestNotificationPermissions();
      verify(() => mockPermission.request()).called(1);
    });

    test('requestNotificationPermissions permanentlyDenied', () async {
      when(() => mockPermission.request())
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(() => Permission.notification).thenReturn(mockPermission);
      when(openAppSettings).thenAnswer((_) async => true);
      await PermissionService.requestNotificationPermissions();
      verify(() => mockPermission.request()).called(1);
      verify(openAppSettings).called(1);
    });
    test('requestLocationPermissions whileInUse', () async {
      when(geo.Geolocator.requestPermission)
          .thenAnswer((_) async => geo.LocationPermission.whileInUse);

      final result = await PermissionService.requestLocationPermissions();

      expect(result, geo.LocationPermission.whileInUse);
    });

    test('requestLocationPermissions always', () async {
      when(geo.Geolocator.requestPermission)
          .thenAnswer((_) async => geo.LocationPermission.always);

      final result = await PermissionService.requestLocationPermissions();

      expect(result, geo.LocationPermission.always);
    });
    test('requestLocationPermissions denied', () async {
      when(geo.Geolocator.requestPermission)
          .thenAnswer((_) async => geo.LocationPermission.denied);

      final result = await PermissionService.requestLocationPermissions();
      expect(result, geo.LocationPermission.denied);
    });
    test('requestLocationPermissions permanentlyDenied', () async {
      when(geo.Geolocator.requestPermission)
          .thenAnswer((_) async => geo.LocationPermission.deniedForever);
      when(geo.Geolocator.openAppSettings).thenAnswer((_) async => true);
      final result = await PermissionService.requestLocationPermissions();
      expect(result, geo.LocationPermission.deniedForever);
      verify(geo.Geolocator.openAppSettings).called(1);
    });
  });
}
