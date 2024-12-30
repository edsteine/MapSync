// lib/shared/widgets/theme_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

class ThemePicker extends ConsumerWidget {
  const ThemePicker({required this.onThemeChanged, super.key});
  final Function(ThemeMode) onThemeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    return Column(
      children: [
        ListTile(
          title: const Text('Light Theme'),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.light,
            groupValue: theme,
            onChanged: (ThemeMode? value) {
              onThemeChanged(value!);
            },
          ),
        ),
        ListTile(
          title: const Text('Dark Theme'),
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