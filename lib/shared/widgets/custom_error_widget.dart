// lib/shared/widgets/error_widget.dart
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
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor ?? Colors.red[100],
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              error,
              style: TextStyle(color: textColor ?? Colors.red[900]),
            ),
          ),
        ),
      );
}
