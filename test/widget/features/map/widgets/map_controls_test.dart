// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile/features/map/widgets/map_controls.dart';

// void main() {
//   testWidgets('MapControls shows download button when not downloading',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: MapControls(
//             onDownloadRegion: () {},
//             isDownloading: false,
//             downloadProgress: 0.0,
//           ),
//         ),
//       ),
//     );

//     expect(find.byIcon(Icons.download), findsOneWidget);
//   });

//   testWidgets('MapControls shows progress indicator when downloading',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: MapControls(
//             onDownloadRegion: () {},
//             isDownloading: true,
//             downloadProgress: 0.5,
//           ),
//         ),
//       ),
//     );

//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//   });
// }
