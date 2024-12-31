// lib/core/performance/performance_monitor.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

// ignore: avoid_classes_with_only_static_members
class PerformanceMonitor {
  static bool _isMonitoring = false;

  static void startMonitoring() {
    if (kDebugMode && !_isMonitoring) {
      _isMonitoring = true;
      debugPrintRebuildDirtyWidgets = true;
      debugPrintLayouts = true;
      debugPrintBeginFrameBanner = true;
      debugPrintEndFrameBanner = true;

      WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    }
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildTime = timing.buildDuration.inMilliseconds;
      final rasterTime = timing.rasterDuration.inMilliseconds;

      if (buildTime > 16 || rasterTime > 16) {
        // Frame dropped, log more details
        final buildDetails = _getBuildDetails();
        debugPrint(
          'Frame drop detected - Build: ${buildTime}ms, Raster: ${rasterTime}ms, Rebuilt Widgets: $buildDetails',
        );
      }
      // Example timer for each method.
      _methodTimer(
        'Raster',
        () {
          // Example of a raster method being timed.
          // You can replace this with any raster method you want to measure
          // const Color color = Colors.red; // Example action
          // final paint = Paint()..color = color;
          // if (kDebugMode) {
          // print('doing some raster work');
          // }
        },
        rasterTime,
      );
      _methodTimer(
        'Build',
        () {
          // Example of a build method being timed.
          // You can replace this with any build method you want to measure
          // Example of a method being timed.
          // final container = Container(color: Colors.blue,); // Example Action
          // if (kDebugMode) {
          //   // print('doing some build work');
          // }
        },
        buildTime,
      );
    }
  }

  static void _methodTimer(String methodName, Function method, int time) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      // method();
      // stopwatch.stop();

      debugPrint(
        '$methodName time: ${time}ms, actual method time: ${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }

  static String _getBuildDetails() {
    final rebuiltWidgets = <String>[];
    // Only do this in debug
    if (kDebugMode) {
      WidgetsBinding.instance.rootElement?.visitChildren((element) {
        if (element is RenderObjectElement) {
          final renderObject = element.renderObject;
          if (renderObject.debugNeedsPaint) {
            final widgetName = element.widget.runtimeType.toString();
            rebuiltWidgets.add(widgetName);
          }
        }
      });
    }
    return rebuiltWidgets.join(', ');
  }

  static void stopMonitoring() {
    if (_isMonitoring) {
      _isMonitoring = false;
      debugPrintRebuildDirtyWidgets = false;
      debugPrintLayouts = false;
      debugPrintBeginFrameBanner = false;
      debugPrintEndFrameBanner = false;
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    }
  }
}
