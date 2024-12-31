// test/shared/widgets/loading_overlay_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/loading_overlay.dart';

void main() {
  group('loading_overlay_widget_test', () {
    testWidgets('loading overlay renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('loading overlay with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(message: 'test message'),
        ),
      );
      expect(find.text('test message'), findsOneWidget);
    });
    testWidgets('loading overlay with cancel', (WidgetTester tester) async {
      var isCanceled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlay(
            onCancel: () {
              isCanceled = true;
            },
          ),
        ),
      );
      await tester.tap(find.text('Cancel'));
      expect(isCanceled, true);
    });
  });
}
