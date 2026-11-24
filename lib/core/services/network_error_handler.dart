///
/// File: lib/core/services/network_error_handler.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Handles Dio errors and provides custom error messages.
/// Updates: Initial setup to handle connection timeouts, receive timeouts, and bad responses, including a default error case.
/// Used Libraries: dio/dio.dart, flutter/foundation.dart, mobile/core/utils/app_constants.dart
///
library;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/utils/app_constants.dart';

// Custom exception for Network errors
// ignore: avoid_classes_with_only_static_members
class NetworkErrorHandler {
   /// Handles Dio errors, converting them into meaningful errors.
  static DioException handle(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
     // Prints the error message and stack trace in debug mode
    if (kDebugMode) {
      print('Network Error: ${error.message} StackTrace: $stackTrace');
    }
     // Handle different types of Dio errors
    switch (error.type) {
     // Handles connection timeouts, receive timeouts, and connection errors, which are treated as a network error.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: error.requestOptions,
          error: AppConstants.networkError,
          type: error.type,
        );
      // Handles bad responses coming from the backend
      case DioExceptionType.badResponse:
        return error;
        // Handles other types of errors that aren't in the cases above
      default:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'Unexpected error occurred',
          type: error.type,
        );
    }
  }
}