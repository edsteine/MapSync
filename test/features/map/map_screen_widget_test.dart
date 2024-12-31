// test/features/map/map_screen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/map/map_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('map_screen_widget_test', () {
    testWidgets('map screen renders', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const MapScreen(),
            navigatorObservers: [mockObserver],
          ),
        ),
      );
      expect(find.byType(MapScreen), findsOneWidget);
    });
    //  testWidgets('refresh button works', (WidgetTester tester) async {
    //       final mockObserver = MockNavigatorObserver();
    //     await tester.pumpWidget(
    //       ProviderScope(
    //         child: MaterialApp(
    //           home: const MapScreen(),
    //           navigatorObservers: [mockObserver],
    //         ),
    //       ),
    //     );

    //    await tester.tap(find.byIcon(Icons.refresh));
    //   //  TODO: Add assertion for the refresh action

    //   });
  });
}
