///
/// File: lib/core/services/permission_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages permission requests for the application, handling both notification and location permissions.
/// Updates: Initial setup with request methods for notification and location permissions.
/// Used Libraries: flutter/foundation.dart, geolocator/geolocator.dart, permission_handler/permission_handler.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

//  PermissionService class provides static methods for requesting app permissions.
// ignore: avoid_classes_with_only_static_members
class PermissionService {
    /// Requests notification permissions from the user, handles denied or permanently denied cases.
  static Future<void> requestNotificationPermissions() async {
      // Requests the notification permission from the user.
    final status = await Permission.notification.request();
    // Prints the status of the notification permission to console in debug mode.
    if (kDebugMode) {
      print('Notification permission status: $status');
    }
     // Handles the case where notification permission is denied.
    if (status.isDenied) {
       // Prints a message to console if the permission is denied
      if (kDebugMode) {
        print('Notification permission is denied');
      }
     //Handles the case where the notification permission is permanently denied,
    } else if (status.isPermanentlyDenied) {
       // Prints a message to console when permission is denied and opening settings
      if (kDebugMode) {
        print(
          'Notification permission is permanently denied, opening app settings',
        );
      }
      // Opens the application settings to allow the user to enable the permission.
      await openAppSettings();
      //Handles the case where permission is granted by the user
    } else if (status.isGranted) {
     // Prints a message to console when permission is granted
      if (kDebugMode) {
        print('Notification permission is granted');
      }
    }
  }

   /// Requests location permissions from the user, returns the permission status.
  static Future<geo.LocationPermission> requestLocationPermissions() async {
    // Requests the location permission from the user.
    final permission = await geo.Geolocator.requestPermission();

   // Handles the case when permission is denied.
    if (permission == geo.LocationPermission.denied) {
      // Do not use the location services, and use default location.
      return geo.LocationPermission.denied;
       // Handles the case when location permission is permanently denied.
    } else if (permission == geo.LocationPermission.deniedForever) {

      // Permission has been denied, try to open the settings.
      if (kDebugMode) {
        print(
          'Location permission is permanently denied',
        );
      }
       // Opens the app settings.
      await geo.Geolocator.openAppSettings();

     // Returns the location permission status as 
      return geo.LocationPermission.deniedForever;
       // Handles the case where permission is granted by the user
    } else if (permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always) {
      // Do use location services.
      return permission;
    }
    return geo.LocationPermission.denied;
  }
}
