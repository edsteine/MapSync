// test/shared/widgets/offline_banner_unit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/offline_banner.dart';

void main() {
  group('offline_banner_unit_test', () {
    testWidgets('offline banner renders offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineBanner(isOffline: true),
        ),
      );
      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });
    testWidgets('offline banner does not render when not offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineBanner(),
        ),
      );
      expect(find.byType(Container), findsNothing);
    });
  });
}
