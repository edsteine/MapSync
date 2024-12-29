// lib/core/performance/app_size_reducer.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:path_provider/path_provider.dart';

// ignore: avoid_classes_with_only_static_members
class AppResourceOptimizer {
  static Future<Uint8List?> compressImage(Uint8List list) async =>
      compute(_compressImage, list);

  static Future<Uint8List?> _compressImage(Uint8List list) async {
    final compressedImage = await FlutterImageCompress.compressWithList(
      list,
      minHeight: AppConfig.compressImageMinHeight,
      minWidth: AppConfig.compressImageMinWidth,
      quality: AppConfig.compressImageQuality,
    );

    if (kDebugMode) {
      print('Compressed image size: ${compressedImage.length} bytes');
    }

    return compressedImage;
  }

  static Future<void> clearTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    for (final file in files) {
      if (file is File) {
        await file.delete();
      }
    }
  }
}
