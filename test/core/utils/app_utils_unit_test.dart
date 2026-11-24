import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/app_utils.dart';

void main() {
  group('AppUtils', () {
    test('formats file sizes', () {
      expect(AppUtils.formatFileSize(0), '0 B');
      expect(AppUtils.formatFileSize(1023), '1023.00 B');
      expect(AppUtils.formatFileSize(1024), '1.00 KB');
      expect(AppUtils.formatFileSize(1500), '1.46 KB');
      expect(AppUtils.formatFileSize(1048576), '1.00 MB');
    });
  });
}
