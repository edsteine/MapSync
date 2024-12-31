///
/// File: lib/core/utils/app_utils.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides utility functions for the application, such as formatting file sizes and handling state errors.
/// Updates: Initial setup with file size formatting and generic error handling.
/// Used Libraries: flutter/foundation.dart, flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/utils/app_constants.dart, mobile/core/utils/context_provider.dart, mobile/core/utils/error_manager.dart
///
library;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/context_provider.dart';
import 'package:mobile/core/utils/error_manager.dart';

// AppUtils class provides static utility functions for the application
// ignore: avoid_classes_with_only_static_members
class AppUtils {
  /// Formats a file size in bytes into human-readable format (B, KB, MB, GB, TB).
  static String formatFileSize(int bytes) {
    // Checks if size is zero, returns '0 B'.
    if (bytes <= 0) {
      return '0 B';
    }
     // Defines suffixes for file sizes.
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    // Calculates the index of the suffix needed for appropriate formatting.
    final i = (log(bytes) / log(1024)).floor();
    // Formats the file size to a readable string with appropriate suffix.
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
// lib/core/utils/app_utils.dart

  /// Generic error handling for state notifiers. It updates state, prints the error, and shows a SnackBar.
  static void handleStateError<T extends StateNotifier<S>, S, R extends Ref>(
    T notifier,
    R ref,
    S state,
    dynamic error,
    String errorMessage,
  ) {
      // Checks if the notifier is still mounted to prevent errors on disposed widgets.
    if (!notifier.mounted) {
      return;
    }
    // Creates a new state with the error message and download status.
    final newState = (state as dynamic).copyWith(
      downloadStatus: DownloadStatus.idle,
      error: errorMessage,
    );

    //Updates the state with the new state.
    notifier.state = newState;
     // Prints the error to the console in debug mode.
    if (kDebugMode) {
      print('Error: $error');
    }
    // Retrieves the current build context from the context provider
    final context = ref.read(contextProvider);
     //Checks if the context is valid for showing the snackbar.
    if (context != null) {
     //Shows a snackbar message to the user with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    // Sets the error in the error provider
    ref.read(errorProvider.notifier).setError(errorMessage);
  }
}