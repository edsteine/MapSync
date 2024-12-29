// lib/core/utils/helpers.dart
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// ignore: avoid_classes_with_only_static_members
class MapHelpers {
  static bool isPointInBounds(Point point, CoordinateBounds bounds) {
    final pointCoords = point.coordinates;
    final southwestCoords = bounds.southwest.coordinates;
    final northeastCoords = bounds.northeast.coordinates;

    return pointCoords[1]! >= southwestCoords[1]! &&
        pointCoords[1]! <= northeastCoords[1]! &&
        pointCoords[0]! >= southwestCoords[0]! &&
        pointCoords[0]! <= northeastCoords[0]!;
  }

  static double calculateDistance(Point point1, Point point2) {
    const double earthRadius = 6371000; // meters

    final coords1 = point1.coordinates;
    final coords2 = point2.coordinates;

    final lat1 = coords1[1]! * math.pi / 180;
    final lat2 = coords2[1]! * math.pi / 180;
    final lon1 = coords1[0]! * math.pi / 180;
    final lon2 = coords2[0]! * math.pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;

        default:
          return error.message.toString().toLowerCase().contains('network') ||
              error.message.toString().toLowerCase().contains('connection');
      }
    }
    return error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection');
  }
}
