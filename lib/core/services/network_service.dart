// lib/core/services/network_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/network_error_handler.dart';


// Custom Exception for Network Service errors
class NetworkServiceException implements Exception {
  NetworkServiceException(this.message, this.error, [this.stackTrace]);
  final String message;
  final dynamic error;
    final StackTrace? stackTrace;

  @override
  String toString() => 'NetworkServiceException: $message, $error, stackTrace: $stackTrace';
}

class NetworkService {
  NetworkService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }
  late final Dio _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('Request: ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('Response: ${response.statusCode} ${response.realUri}');
          }
          return handler.next(response);
        },
         onError: (error, handler) {
          if (kDebugMode) {
            print('Error: ${error.message} ${error.requestOptions.uri}');
          }
           return handler.next(_handleError(error, error.stackTrace));
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

  Future<Response> getWithPages(
    String path, {
    int page = 1,
    int pageSize = 150,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e, stackTrace) {
       throw _handleError(e, stackTrace);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e, stackTrace) {
       throw _handleError(e, stackTrace);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e, stackTrace) {
     throw _handleError(e, stackTrace);
    }
  }


     DioException _handleError(DioException error, StackTrace? stackTrace) {
         throw NetworkErrorHandler.handle(error, stackTrace);
     }


}

final networkServiceProvider =
    Provider<NetworkService>((ref) => NetworkService());