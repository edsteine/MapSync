// lib/core/services/network_error_handler.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/services/network_service.dart';
import 'package:mobile/core/utils/app_constants.dart';

// Custom exception for Network errors
// ignore: avoid_classes_with_only_static_members
class NetworkErrorHandler {
  static NetworkServiceException handle(DioException error, [StackTrace? stackTrace]) {
      if (kDebugMode) {
        print('Network Error: ${error.message} StackTrace: $stackTrace');
      }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkServiceException(
          AppConstants.networkError,
          error,
          stackTrace,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkServiceException(
          AppConstants.networkError,
          error,
          stackTrace,
        );
        case DioExceptionType.connectionError:
        return NetworkServiceException(
          AppConstants.networkError,
          error,
          stackTrace,
        );
       case DioExceptionType.badResponse:
         return NetworkServiceException(
            'Server error: ${error.response?.statusCode}',
            error,
             stackTrace,
        );
      default:
        return NetworkServiceException('Unexpected error occurred', error, stackTrace);
    }
  }

}