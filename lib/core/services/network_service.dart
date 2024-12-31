///
/// File: lib/core/services/network_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Handles network requests using Dio, including setting up interceptors for logging and error handling.
/// Updates: Initial setup with get, post, put, and delete methods, along with interceptors for request/response/error logging and handling.
/// Used Libraries: dio/dio.dart, flutter/foundation.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/config/app_config.dart, mobile/core/services/network_error_handler.dart
///
library;
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
  String toString() =>
      'NetworkServiceException: $message, $error, stackTrace: $stackTrace';
}

/// NetworkService class provides methods for making network requests.
class NetworkService {
    /// Constructor for the network service setting configurations and interceptors.
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
  /// Dio client used for making requests
  late final Dio _dio;

    /// Configures interceptors for requests, responses, and errors.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
           // Logs the request method and url in debug mode.
          if (kDebugMode) {
            print('Request: ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
           // Logs the response status code and url in debug mode.
          if (kDebugMode) {
            print('Response: ${response.statusCode} ${response.realUri}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // Logs the error message and url in debug mode.
          if (kDebugMode) {
            print('Error: ${error.message} ${error.requestOptions.uri}');
          }
           // Handles the error before passing to the next handler.
          return handler.next(_handleError(error, error.stackTrace));
        },
      ),
    );
  }

   /// Performs a GET request to the specified path.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
       // Executes the get method.
      return await _dio.get(path, queryParameters: queryParameters);
      // Handles Dio exceptions.
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

   /// Handles errors from Dio by calling the NetworkErrorHandler.
  DioException _handleError(DioException error, StackTrace? stackTrace) {
    throw NetworkErrorHandler.handle(error, stackTrace);
  }

   /// Performs a GET request with pagination to the specified path.
  Future<Response> getWithPages(
    String path, {
    int page = 1,
    int pageSize = 150,
  }) async {
    try {
       // Construct the query parameters with page and page size.
      final queryParameters = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
       // Executes the get method with the added query parameters.
      return await _dio.get(path, queryParameters: queryParameters);
       // Handles Dio exceptions.
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

    /// Performs a POST request to the specified path with the given data.
  Future<Response> post(String path, dynamic data) async {
    try {
      // Executes the post method.
      return await _dio.post(path, data: data);
      // Handles Dio exceptions.
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

  /// Performs a PUT request to the specified path with the given data.
  Future<Response> put(String path, dynamic data) async {
    try {
       // Executes the put method
      return await _dio.put(path, data: data);
      // Handles Dio exceptions.
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }

    /// Performs a DELETE request to the specified path.
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      // Executes the delete method
      return await _dio.delete(path, data: data);
      // Handles Dio exceptions.
    } on DioException catch (e, stackTrace) {
      throw _handleError(e, stackTrace);
    }
  }
}

/// Provider for the NetworkService to manage network requests throughout the app
final networkServiceProvider =
    Provider<NetworkService>((ref) => NetworkService());