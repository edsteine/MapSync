// lib/features/map/widgets/offline_banner.dart
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.isOffline = false});
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
