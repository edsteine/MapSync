// lib/shared/widgets/loading_overlay.dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message, this.onCancel});
  final String? message;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    message!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      );
}