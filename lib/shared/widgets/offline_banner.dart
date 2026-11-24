///
/// File: lib/shared/widgets/offline_banner.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a banner when the application is in offline mode.
/// Updates: Initial setup for displaying the banner when the offline flag is true.
/// Used Libraries: flutter/material.dart
///
library;
import 'package:flutter/material.dart';

/// OfflineBanner widget is displayed when the app is in offline mode.
class OfflineBanner extends StatelessWidget {
    /// Constructor for the `OfflineBanner` widget, takes `isOffline` boolean as a parameter.
  const OfflineBanner({super.key, this.isOffline = false});
    /// Boolean flag to indicate if the application is offline.
  final bool isOffline;
  @override
  Widget build(BuildContext context) => isOffline
      ? Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.orange,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Offline Mode',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      : const SizedBox();
}