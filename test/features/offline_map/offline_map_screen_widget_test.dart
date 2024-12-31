// test/features/offline_map/offline_map_screen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/offline_map/offline_map_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('offline_map_screen_widget_test', () {
    testWidgets('offline map screen renders', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OfflineMapScreen(),
            navigatorObservers: [mockObserver],
          ),
        ),
      );
      expect(find.byType(OfflineMapScreen), findsOneWidget);
    });
    // TODO: Add test for download button
    //TODO: Add test for map button
    // testWidgets('show download dialog', (WidgetTester tester) async {
    //    final mockObserver = MockNavigatorObserver();
    //     await tester.pumpWidget(
    //       ProviderScope(
    //         child: MaterialApp(
    //           home: const OfflineMapScreen(),
    //           navigatorObservers: [mockObserver],
    //         ),
    //       ),
    //     );
    //       await tester.tap(find.byIcon(Icons.download));

    //       expect(find.byType(AlertDialog), findsOneWidget);
    // });
    // testWidgets('show regions dialog', (WidgetTester tester) async {
    //  final mockObserver = MockNavigatorObserver();
    //   await tester.pumpWidget(
    //     ProviderScope(
    //       child: MaterialApp(
    //         home: const OfflineMapScreen(),
    //         navigatorObservers: [mockObserver],
    //       ),
    //     ),
    //   );
    //     await tester.tap(find.byIcon(Icons.map));
    //      expect(find.byType(AlertDialog), findsOneWidget);
    // });
  });
}
