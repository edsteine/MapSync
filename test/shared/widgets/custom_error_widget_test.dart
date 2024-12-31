// test/shared/widgets/custom_error_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/custom_error_widget.dart';

void main() {
  group('custom_error_widget_test', () {
    testWidgets('custom error widget renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomErrorWidget(error: 'test error'),
        ),
      );
      expect(find.text('test error'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
    testWidgets('custom error widget onClose works',
        (WidgetTester tester) async {
      var isClosed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CustomErrorWidget(
            error: 'test error',
            onClose: () {
              isClosed = true;
            },
          ),
        ),
      );
      await tester.tap(find.text('Close'));
      expect(isClosed, true);
    });
  });
}
