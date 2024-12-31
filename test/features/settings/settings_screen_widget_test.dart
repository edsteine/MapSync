// test/features/settings/settings_screen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/settings/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('settings_screen_widget_test', () {
    testWidgets('settings screen renders', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsScreen(),
            navigatorObservers: [mockObserver],
          ),
        ),
      );
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
    //TODO: add widget test for theme change
    // TODO: Add widget test for clear cache function
    //  testWidgets('theme change works', (WidgetTester tester) async {
    //       final mockObserver = MockNavigatorObserver();
    //   await tester.pumpWidget(
    //      ProviderScope(
    //         child: MaterialApp(
    //           home: const SettingsScreen(),
    //          navigatorObservers: [mockObserver],
    //         ),
    //       ),
    //     );
    //      await tester.tap(find.text('Dark Theme'));
    //       //TODO: add assertion that theme has changed
    //   });
  });
}
