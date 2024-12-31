// test/core/services/network_service_unit_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('network_service_unit_test', () {
    late NetworkService networkService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      networkService = NetworkService();
      // Replace the _dio instance with mockDio
    });

    test('get success', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: {'test': 'data'},
          statusCode: 200,
        ),
      );

      final response = await networkService.get('/test');
      expect(response.statusCode, 200);
      expect(response.data, {'test': 'data'});
    });

    test('get failure', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 404),
        ),
      );

      expect(
        () async => networkService.get('/test'),
        throwsA(isA<DioException>()),
      );
    });
    test('post success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: {'test': 'data'},
          statusCode: 201,
        ),
      );
      final response = await networkService.post('/test', {'test': 'data'});
      expect(response.statusCode, 201);
      expect(response.data, {'test': 'data'});
    });
    test('post failure', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 400),
        ),
      );
      expect(
        () async => networkService.post('/test', {'test': 'data'}),
        throwsA(isA<DioException>()),
      );
    });
    test('put success', () async {
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: {'test': 'data'},
          statusCode: 200,
        ),
      );

      final response = await networkService.put('/test', {'test': 'data'});
      expect(response.statusCode, 200);
      expect(response.data, {'test': 'data'});
    });
    test('put failure', () async {
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 404),
        ),
      );
      expect(
        () async => networkService.put('/test', {'test': 'data'}),
        throwsA(isA<DioException>()),
      );
    });
    test('delete success', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(), statusCode: 204),
      );
      final response = await networkService.delete('/test');
      expect(response.statusCode, 204);
    });
    test('delete failure', () async {
      when(() => mockDio.delete(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 400),
        ),
      );
      expect(
        () async => networkService.delete('/test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
