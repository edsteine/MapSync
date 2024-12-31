///
/// File: lib/shared/widgets/loading_overlay.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a loading overlay with a progress indicator and optional message, used during long processes.
/// Updates: Initial setup for loading overlay with optional message and cancel option.
/// Used Libraries: flutter/material.dart
///
library;
import 'package:flutter/material.dart';

/// LoadingOverlay widget displays a loading indicator, an optional message, and an optional cancel button.
class LoadingOverlay extends StatelessWidget {
    /// Constructor for the `LoadingOverlay` widget, it takes a message and a cancel callback as optional parameters.
  const LoadingOverlay({super.key, this.message, this.onCancel});
   /// Message to display under the loading indicator.
  final String? message;
    /// Callback when the cancel button is clicked.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Circular loading indicator with white color.
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
                // Shows the message if there is any, otherwise, it's not shown.
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    message!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                //Shows the cancel button when the callback is provided.
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