// test/core/performance/performance_monitor_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/performance/performance_monitor.dart';

void main() {
  group('performance_monitor_unit_test', () {
    test('startMonitoring and stopMonitoring', () {
      PerformanceMonitor.startMonitoring();
      expect(PerformanceMonitor.isMonitoring, true);
      PerformanceMonitor.stopMonitoring();
      expect(PerformanceMonitor.isMonitoring, false);
    });
  });
}
