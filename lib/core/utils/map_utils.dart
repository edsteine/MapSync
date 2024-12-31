///
/// File: lib/core/utils/map_utils.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides utility functions related to map operations, such as checking if a point is in bounds and calculating distances.
/// Updates: Initial setup with functions to check point in bounds and calculate distance.
/// Used Libraries: mapbox_maps_flutter/mapbox_maps_flutter.dart
///
library;
import 'dart:math' as math;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// MapUtils class provides static utility functions for map-related operations
// ignore: avoid_classes_with_only_static_members
class MapUtils {
    /// Checks if a given point is within the specified coordinate bounds.
  static bool isPointInBounds(Point point, CoordinateBounds bounds) {
    // Get the coordinates of the point
    final pointCoords = point.coordinates;
     // Get the coordinates of the southwest bound
    final southwestCoords = bounds.southwest.coordinates;
     // Get the coordinates of the northeast bound
    final northeastCoords = bounds.northeast.coordinates;

    // Checks if the point is within the bounds
    return pointCoords[1]! >= southwestCoords[1]! &&
        pointCoords[1]! <= northeastCoords[1]! &&
        pointCoords[0]! >= southwestCoords[0]! &&
        pointCoords[0]! <= northeastCoords[0]!;
  }

    /// Calculates the distance in meters between two points using the Haversine formula.
  static double calculateDistance(Point point1, Point point2) {
    const double earthRadius = 6371000; // meters
     // Get the coordinates of the first point
    final coords1 = point1.coordinates;
     // Get the coordinates of the second point
    final coords2 = point2.coordinates;

    final lat1 = coords1[1]! * math.pi / 180; // Convert latitude of point1 to radians
    final lat2 = coords2[1]! * math.pi / 180;// Convert latitude of point2 to radians
    final lon1 = coords1[0]! * math.pi / 180;// Convert longitude of point1 to radians
    final lon2 = coords2[0]! * math.pi / 180;// Convert longitude of point2 to radians

    final dLat = lat2 - lat1; // Calculate the difference in latitude
    final dLon = lon2 - lon1;// Calculate the difference in longitude

     // Haversine formula to calculate the distance between two points.
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
     // Returns the distance in meters
    return earthRadius * c;
  }
}