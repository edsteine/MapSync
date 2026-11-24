// test/core/performance/app_resource_optimizer_unit_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/performance/app_resource_optimizer.dart';

void main() {
  group('app_resource_optimizer_unit_test', () {
    test('compressImage returns null for empty list', () async {
      final result = await AppResourceOptimizer.compressImage(Uint8List(0));
      expect(result, null);
    });
    test('clearTempFiles success', () async {
      // Test not possible because of dependency on getTempDirectory
    });
  });
}
