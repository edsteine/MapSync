// test/shared/widgets/map_widget_unit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/shared/widgets/map_widget.dart';
import 'package:mocktail/mocktail.dart';

class MockMapboxMap extends Mock implements MapboxMap {}

void main() {
  group('map_widget_unit_test', () {
    testWidgets('custom map widget renders', (WidgetTester tester) async {
      final mockMapboxMap = MockMapboxMap();
      await tester.pumpWidget(
        MaterialApp(
          home: CustomMapWidget(
            cameraOptions: CameraOptions(),
            onMapCreated: (map) {
              mockMapboxMap;
            },
            styleUri: 'test',
          ),
        ),
      );
      expect(find.byType(MapWidget), findsOneWidget);
    });
  });
}
