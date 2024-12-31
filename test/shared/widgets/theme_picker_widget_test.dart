// test/shared/widgets/theme_picker_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/theme_picker.dart';

void main() {
  group('theme_picker_widget_test', () {
    testWidgets('theme picker renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThemePicker(onThemeChanged: (_) {}),
        ),
      );
      expect(find.text('Light Theme'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.byType(Radio<ThemeMode>), findsNWidgets(2));
    });
    testWidgets('theme change works', (WidgetTester tester) async {
      ThemeMode? selectedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: ThemePicker(
            onThemeChanged: (theme) {
              selectedTheme = theme;
            },
          ),
        ),
      );
      await tester.tap(find.text('Dark Theme'));

      expect(selectedTheme, ThemeMode.dark);
    });
  });
}
