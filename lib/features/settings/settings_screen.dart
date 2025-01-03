///
/// File: lib/features/settings/settings_screen.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays the settings screen, allowing users to change the application theme and clear data.
/// Updates: Initial setup with theme picker, clear data options, and downloaded region display.
/// Used Libraries: flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mobile/features/settings/settings_viewmodel.dart, mobile/shared/widgets/theme_picker.dart
///
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/settings/settings_viewmodel.dart';
import 'package:mobile/shared/widgets/theme_picker.dart';

/// SettingsScreen widget provides UI to change app theme, clear data, and list downloaded regions.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Adding a callback to load regions after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsViewModelProvider.notifier).loadRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gets the view model to execute actions
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);
    return Scaffold(
       // AppBar with the title "Settings".
      appBar: AppBar(title: const Text('Settings')),
       // Padding and a column to arrange the components.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           //Section title for the theme settings
            const Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Theme picker for changing application themes
            ThemePicker(
              onThemeChanged: settingsViewModel.changeTheme,
            ),
            const SizedBox(height: 20),
           //Section title for app performance settings
            const Text(
              'Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // ListTile to clear the application cache.
            ListTile(
              title: const Text('Clear Data'),
              onTap: () {
                settingsViewModel.clearData(context);
              },
            ),
            // ListTile(
            //   title: const Text('Clear System Cache'),
            //   onTap: () {
            //     settingsViewModel.clearSystemCache(context);
            //   },
            // ),
            const SizedBox(height: 20),
            //Section title for the downloaded regions.
            const Text(
              'Downloaded Regions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // List to show the downloaded regions
            // Expanded(
            //   child: Consumer(
            //     builder: (BuildContext context, WidgetRef ref, Widget? child) {
            //       final state = ref.watch(settingsViewModelProvider);
            //       return state.isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
            //         itemCount: state.regions.length,
            //         itemBuilder: (context, index) => RegionItem(
            //           region: state.regions[index],
            //           deleteRegion: (regionId) {
            //             settingsViewModel.deleteRegion(regionId);
            //           },
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}