// lib/core/services/network_error_handler.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/utils/app_constants.dart';

// Custom exception for Network errors
// ignore: avoid_classes_with_only_static_members
class NetworkErrorHandler {
  static DioException handle(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print('Network Error: ${error.message} StackTrace: $stackTrace');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return DioException(
            requestOptions: error.requestOptions,
            error: AppConstants.networkError,
            type: error.type,);

      case DioExceptionType.badResponse:
        return error;
      default:
        return DioException(
            requestOptions: error.requestOptions,
            error: 'Unexpected error occurred',
            type: error.type,);
    }
  }
}
