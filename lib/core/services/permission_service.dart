// lib/core/services/permission_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

// ignore: avoid_classes_with_only_static_members
class PermissionService {
  static Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    if (kDebugMode) {
      print('Notification permission status: $status');
    }
    if (status.isDenied) {
      // Handle case when the permission is denied by the user.
      if (kDebugMode) {
        print('Notification permission is denied');
      }
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print(
          'Notification permission is permanently denied, opening app settings',
        );
      }
      await openAppSettings();
    } else if (status.isGranted) {
      // Permission is granted by the user, use notification services
      if (kDebugMode) {
        print('Notification permission is granted');
      }
    }
  }

  static Future<geo.LocationPermission> requestLocationPermissions() async {
    final permission = await geo.Geolocator.requestPermission();

    if (permission == geo.LocationPermission.denied) {
      // Do not use the location services, and use default location.
      return geo.LocationPermission.denied;
    } else if (permission == geo.LocationPermission.deniedForever) {
      // Permission has been denied, try to open the settings.
       if (kDebugMode) {
        print(
          'Location permission is permanently denied',
        );
      }
       await geo.Geolocator.openAppSettings();

      return geo.LocationPermission.deniedForever;
    } else if (permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always) {
      // Do use location services.
      return permission;
    }
    return geo.LocationPermission.denied;
  }
}