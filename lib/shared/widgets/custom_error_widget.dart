// lib/shared/widgets/custom_error_widget.dart
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    required this.error,
    super.key,
    this.backgroundColor,
    this.textColor,
  });
  final String error;
  final Color? backgroundColor;
  final Color? textColor;

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
                   Expanded(
                     child: SingleChildScrollView(
                        child: Text(
                            error,
                           style: TextStyle(color: textColor ?? Colors.red[900]),
                         ),
                      ),
                   ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
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