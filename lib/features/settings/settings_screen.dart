// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/settings/settings_viewmodel.dart';
import 'package:mobile/shared/widgets/theme_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsViewModelProvider.notifier).loadRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ThemePicker(
              onThemeChanged: settingsViewModel.changeTheme,
            ),
            const SizedBox(height: 20),
            const Text(
              'Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
            const Text(
              'Downloaded Regions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
