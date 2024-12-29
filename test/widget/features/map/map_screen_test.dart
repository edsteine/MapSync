// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/features/map/map_screen.dart';

// void main() {
//   testWidgets('MapScreen shows offline banner when offline',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const ProviderScope(
//         child: MaterialApp(
//           home: MapScreen(),
//         ),
//       ),
//     );

//     await tester.pumpAndSettle();
//     expect(find.text('Offline Mode'), findsOneWidget);
//   });

//   testWidgets('MapScreen shows download button', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const ProviderScope(
//         child: MaterialApp(
//           home: MapScreen(),
//         ),
//       ),
//     );

//     expect(find.byIcon(Icons.download), findsOneWidget);
//   });
// }
