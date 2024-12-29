// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile/features/map/widgets/offline_banner.dart';

// void main() {
//   testWidgets('OfflineBanner shows correct text',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: Scaffold(
//           body: OfflineBanner(),
//         ),
//       ),
//     );

//     expect(find.text('Offline Mode'), findsOneWidget);
//   });

//   testWidgets('OfflineBanner has correct color',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: Scaffold(
//           body: OfflineBanner(),
//         ),
//       ),
//     );

//     final container = tester.widget<Container>(find.byType(Container));
//     expect(container.color, Colors.orange);
//   });
// }
