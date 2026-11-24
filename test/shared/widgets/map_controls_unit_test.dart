// test/shared/widgets/map_controls_unit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/map_controls.dart';

void main() {
  group('map_controls_unit_test', () {
    testWidgets('map controls render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MapControls(
            onZoomIn: () {},
            onZoomOut: () {},
            onMoveToCurrentLocation: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });
    testWidgets('map controls tap', (WidgetTester tester) async {
      var zoomIn = false;
      var zoomOut = false;
      var location = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MapControls(
            onZoomIn: () {
              zoomIn = true;
            },
            onZoomOut: () {
              zoomOut = true;
            },
            onMoveToCurrentLocation: () {
              location = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(zoomIn, true);

      await tester.tap(find.byIcon(Icons.remove));
      expect(zoomOut, true);

      await tester.tap(find.byIcon(Icons.my_location));
      expect(location, true);
    });
  });
}
