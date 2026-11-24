///
/// File: lib/shared/widgets/theme_picker.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a theme picker that allows users to select between light and dark themes.
/// Updates: Initial setup with radio buttons for theme selection.
/// Used Libraries: flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mobile/main.dart
///
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

/// ThemePicker widget enables users to switch between light and dark themes using radio buttons.
class ThemePicker extends ConsumerWidget {
    /// Constructor for the `ThemePicker` widget, takes `onThemeChanged` callback as a parameter
  const ThemePicker({required this.onThemeChanged, super.key});
   /// Callback function that is called when a theme has changed.
  final Function(ThemeMode) onThemeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      // Gets the current selected theme.
    final theme = ref.watch(themeModeProvider);
    return Column(
      children: [
        ListTile(
           // ListTile that shows the label for light theme.
          title: const Text('Light Theme'),
           // Radio button for the light theme.
          trailing: Radio<ThemeMode>(
            value: ThemeMode.light,
            groupValue: theme,
            onChanged: (ThemeMode? value) {
              onThemeChanged(value!);
            },
          ),
        ),
         // ListTile that shows the label for dark theme.
        ListTile(
          title: const Text('Dark Theme'),
            // Radio button for dark theme.
          trailing: Radio<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: theme,
            onChanged: (ThemeMode? value) {
              onThemeChanged(value!);
            },
          ),
        ),
      ],
    );
  }
}