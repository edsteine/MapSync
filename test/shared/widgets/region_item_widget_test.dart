// test/features/settings/widgets/region_item_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/shared/widgets/region_item.dart';

void main() {
  group('region_item_widget_test', () {
    testWidgets('region item renders', (WidgetTester tester) async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: RegionItem(region: region, deleteRegion: (_) {}),
        ),
      );
      expect(find.text('test'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
    testWidgets('delete region works', (WidgetTester tester) async {
      final region = TileRegion(
        id: 'test',
        completedResourceSize: 10,
        completedResourceCount: 10,
        requiredResourceCount: 10,
      );

      var isDeleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: RegionItem(
            region: region,
            deleteRegion: (_) {
              isDeleted = true;
            },
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.delete));
      expect(isDeleted, true);
    });
  });
}
