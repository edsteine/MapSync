// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile/features/map/map_screen.dart';
// import 'package:mobile/main.dart';
// import 'package:flutter/material.dart';
// import 'package:patrol/patrol.dart';

// void main() {
//   patrolTest(
//     'counter state is the same after going to home and going back',
//     ($) async {
//     testWidgets('Complete flow test', (tester) async {
//       await tester.pumpWidget(const MyApp());
//       await tester.pumpAndSettle();

//       // Test map loading
//       expect(find.byType(MapScreen), findsOneWidget);

//       // Test marker addition
//       await tester.tap(find.byIcon(Icons.refresh));
//       await tester.pumpAndSettle();

//       // Test offline download
//       await tester.tap(find.byIcon(Icons.download));
//       await tester.pumpAndSettle();

//       // Verify download progress indicator appears
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });
//   });
// }
