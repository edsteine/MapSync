// lib/core/utils/app_utils.dart
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/utils/context_provider.dart';
import 'package:mobile/core/utils/error_manager.dart';

// ignore: avoid_classes_with_only_static_members
class AppUtils {
  static String formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static void handleStateError<T extends StateNotifier<S>, S, R extends Ref>(
    T notifier,
    R ref,
    S state,
    dynamic error,
    String errorMessage,
  ) {
    if (!notifier.mounted) {
      return;
    }
    final newState = (state as dynamic).copyWith(
      isLoading: false,
      error: errorMessage,
    );

    notifier.state = newState;
    if (kDebugMode) {
      print('Error: $error');
    }
    final context = ref.read(contextProvider);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    ref.read(errorProvider.notifier).setError(errorMessage);
  }
}