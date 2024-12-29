// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:dio/dio.dart';
// import 'package:mobile/core/network.dart';

// class MockDio extends Mock implements Dio {}

// void main() {
//   late NetworkClient networkClient;
//   late MockDio mockDio;

//   setUp(() {
//     mockDio = MockDio();
//     networkClient = NetworkClient();
//   });

//   group('NetworkClient Tests', () {
//     test('get request success', () async {
//       when(mockDio.get(any)).thenAnswer(
//         (_) async => Response(
//           data: {'success': true},
//           statusCode: 200,
//           requestOptions: RequestOptions(),
//         ),
//       );

//       final response = await networkClient.get('/test');
//       expect(response.statusCode, 200);
//     });

//     test('handles network error', () async {
//       when(mockDio.get(any)).thenThrow(DioError(
//         requestOptions: RequestOptions(),
//         type: DioErrorType.connectionTimeout,
//       ));

//       expect(
//         () => networkClient.get('/test'),
//         throwsA(isA<Exception>()),
//       );
//     });
//   });
// }
