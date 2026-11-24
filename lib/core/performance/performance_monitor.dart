///
/// File: lib/core/performance/performance_monitor.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides functionalities for monitoring the performance of the Flutter application, such as frame timings and widget rebuilds.
/// Updates: Initial setup with start and stop monitoring functionalities and frame timings.
/// Used Libraries: flutter/foundation.dart, flutter/material.dart, flutter/rendering.dart, flutter/scheduler.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

//  PerformanceMonitor class provides static functions for monitoring application performance.
// ignore: avoid_classes_with_only_static_members
class PerformanceMonitor {
    /// Boolean indicating if the monitoring is active.
  static bool isMonitoring = false;

    /// Starts the performance monitoring if in debug mode, prints rebuilds, layouts, and frame timing.
  static void startMonitoring() {
    if (kDebugMode && !isMonitoring) {
      isMonitoring = true;
      debugPrintRebuildDirtyWidgets = true;
      debugPrintLayouts = true;
      debugPrintBeginFrameBanner = true;
      debugPrintEndFrameBanner = true;

       // Adds a callback for frame timings.
      WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    }
  }

   /// Handles frame timings, logging details about build and raster durations.
  static void _onFrameTimings(List<FrameTiming> timings) {
    // Loops over the frame timings.
    for (final timing in timings) {
      final buildTime = timing.buildDuration.inMilliseconds;
      final rasterTime = timing.rasterDuration.inMilliseconds;

      // Logs details for dropped frames if the time is over the recommended 16 ms.
      if (buildTime > 16 || rasterTime > 16) {
         // Gathers details about which widgets were rebuilt
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
   /// Measures and logs time for a method execution.
  static void _methodTimer(String methodName, Function method, int time) {
     //  Executes only in debug mode.
    if (kDebugMode) {
     // Starts a stopwatch before the method execution
      final stopwatch = Stopwatch()..start();
      // method();
      // stopwatch.stop();
       //Prints the method time.
      debugPrint(
        '$methodName time: ${time}ms, actual method time: ${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }

   /// Gathers and returns a string of names of the widgets that were rebuilt.
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
     // Returns a string of the rebuilt widgets.
    return rebuiltWidgets.join(', ');
  }

    /// Stops the performance monitoring, resets the debug print flags, and removes the timings callback.
  static void stopMonitoring() {
    if (isMonitoring) {
      isMonitoring = false;
      debugPrintRebuildDirtyWidgets = false;
      debugPrintLayouts = false;
      debugPrintBeginFrameBanner = false;
      debugPrintEndFrameBanner = false;
       // Removes the callback for frame timings.
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    }
  }
}