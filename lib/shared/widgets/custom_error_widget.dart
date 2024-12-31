///
/// File: lib/shared/widgets/custom_error_widget.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a custom error message widget with a close button.
/// Updates: Initial setup for displaying errors with custom background and text colors.
/// Used Libraries: flutter/material.dart
///
library;
import 'package:flutter/material.dart';

/// CustomErrorWidget displays an error message with a close button and customizable styles.
class CustomErrorWidget extends StatelessWidget {
    /// Constructor for the `CustomErrorWidget`, it takes the error message, background color, text color and a close callback as a parameter.
  const CustomErrorWidget({
    required this.error,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.onClose,
  });
   /// Error message to show in the error widget
  final String error;
    /// Background color for error widget, defaults to red if no color is given.
  final Color? backgroundColor;
    /// Color of the text in the error widget, defaults to red[900] if no color is provided.
  final Color? textColor;
  /// Callback function that's called when the close button is pressed.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor ?? Colors.red[100],
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 // SingleChildScrollView to make sure that the text doesn't overflows the available space
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        error,
                        style: TextStyle(color: textColor ?? Colors.red[900]),
                      ),
                    ),
                  ),
                     // Button to close the error dialog.
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: onClose ?? () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}