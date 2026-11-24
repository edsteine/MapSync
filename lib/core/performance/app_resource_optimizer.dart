///
/// File: lib/core/performance/app_resource_optimizer.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides utility functions for optimizing application resources, such as compressing images and clearing temporary files.
/// Updates: Initial setup with image compression and temporary file cleaning.
/// Used Libraries: dart/io.dart, flutter/foundation.dart, flutter_image_compress/flutter_image_compress.dart, mobile/core/config/app_config.dart, path_provider/path_provider.dart
///
library;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:path_provider/path_provider.dart';

// AppResourceOptimizer class provides static utility functions for app resources optimization
// ignore: avoid_classes_with_only_static_members
class AppResourceOptimizer {
  /// Compresses an image represented as a Uint8List, using compute to execute on a separate thread.
  static Future<Uint8List?> compressImage(Uint8List list) async =>
      compute(_compressImage, list);

  ///  Internal function to perform the image compression.
  static Future<Uint8List?> _compressImage(Uint8List list) async {
     //Checks if the image is not empty before compressing.
    if (list.isEmpty) {
      return null;
    }
     // Compress the image with configured height, width, and quality.
    final compressedImage = await FlutterImageCompress.compressWithList(
      list,
      minHeight: AppConfig.compressImageMinHeight,
      minWidth: AppConfig.compressImageMinWidth,
      quality: AppConfig.compressImageQuality,
    );
    // Prints the compressed image size to the console in debug mode.
    if (kDebugMode) {
      print('Compressed image size: ${compressedImage.length} bytes');
    }
    // Returns the compressed image
    return compressedImage;
  }

    /// Clears temporary files from the application's temporary directory.
  static Future<void> clearTempFiles() async {
      // Get the temporary directory.
    final tempDir = await getTemporaryDirectory();
    //  Gets all files inside the temp directory.
    final files = tempDir.listSync();
     // Loops over the files
    for (final file in files) {
      if (file is File) {
        try {
          // Tries to delete the current file.
          await file.delete();
         // Prints an error if the file cannot be deleted
        } on Exception catch (e) {
          if (kDebugMode) {
            print('Error deleting file: $e');
          }
        }
      }
    }
  }
}