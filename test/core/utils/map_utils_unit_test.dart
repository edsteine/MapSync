// test/core/utils/map_utils_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/core/utils/map_utils.dart';

void main() {
  group('map_utils_unit_test', () {
    test('isPointInBounds true', () {
      final point = Point(coordinates: Position(1, 1));
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(2, 2)),
        infiniteBounds: true,
      );
      expect(MapUtils.isPointInBounds(point, bounds), true);
    });
    test('isPointInBounds false', () {
      final point = Point(coordinates: Position(3, 3));
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(0, 0)),
        northeast: Point(coordinates: Position(2, 2)),
        infiniteBounds: true,
      );
      expect(MapUtils.isPointInBounds(point, bounds), false);
    });

    test('calculateDistance', () {
      final point1 = Point(coordinates: Position(0, 0));
      final point2 = Point(coordinates: Position(1, 1));
      final distance = MapUtils.calculateDistance(point1, point2);

      expect(distance, isNonZero);
    });
  });
}
