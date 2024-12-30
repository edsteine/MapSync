// lib/core/utils/app_utils.dart
import 'dart:math';

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
}