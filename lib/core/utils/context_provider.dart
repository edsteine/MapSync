///
/// File: lib/core/utils/context_provider.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides a way to access the current BuildContext throughout the application.
/// Updates: Initial setup, used to get current BuildContext for operations.
/// Used Libraries: flutter/material.dart, flutter_riverpod/flutter_riverpod.dart
///
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Context provider allows other parts of application to access build context.
final contextProvider = StateProvider<BuildContext?>((ref) => null);