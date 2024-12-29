// lib/features/settings/settings_viewmodel.dart
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/settings/settings_repository.dart';
import 'package:mobile/main.dart';

// Custom exception for SettingsViewModel errors
class SettingsViewModelException implements Exception {
  SettingsViewModelException(this.message);
  final String message;

  @override
  String toString() => 'SettingsViewModelException: $message';
}

class SettingsState {
  SettingsState({
    this.themeMode = ThemeMode.light,
    this.regions = const [],
    this.isLoading = false,
  });
  final ThemeMode themeMode;
  final List<String> regions;
  final bool isLoading;

  SettingsState copyWith({
    ThemeMode? themeMode,
    List<String>? regions,
    bool? isLoading,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        regions: regions ?? this.regions,
        isLoading: isLoading ?? this.isLoading,
      );
}

final settingsViewModelProvider =
    StateNotifierProvider.autoDispose<SettingsViewModel, SettingsState>((ref) {
  final storageAsyncValue = ref.watch(storageProvider2); // watch the AsyncValue
  final storage = storageAsyncValue.when(
    data: (data) => data,
    error: (error, stack) =>
        throw SettingsViewModelException('Error loading storage: $error'),
    loading: () => null, // Or some other default
  );

  if (storage == null) {
    return SettingsViewModel(
      ref.watch(settingsRepositoryProvider),
      ref.watch(tileManagerServiceProvider),
      Future.value(Storage()),
      ref.watch(themeModeProvider.notifier),
      ref,
    );
  }
  return SettingsViewModel(
    ref.watch(settingsRepositoryProvider),
    ref.watch(tileManagerServiceProvider),
    Future.value(storage),
    ref.watch(themeModeProvider.notifier),
    ref,
  );
});

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(
    this._repository,
    this._tileManagerService,
    this._storage,
    this._themeModeNotifier,
    this.ref,
  ) : super(SettingsState()) {
    _storage.then((value) {
      // ignore: unnecessary_null_comparison
      if (value != null) {
        loadRegions();
      }
    });
  }
  final SettingsRepository _repository;
  final TileService _tileManagerService;
  final StateController<ThemeMode> _themeModeNotifier;
  late final Future<Storage> _storage;
  final Ref ref;

  void changeTheme(ThemeMode themeMode) {
    if (!mounted) {
      return;
    }
    _themeModeNotifier.state = themeMode;
    _storage.then(
      (storage) =>
          storage.saveString(AppConstants.themeModeKey, themeMode.name),
    );
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> loadRegions() async {
    if (kDebugMode) {
      print('Loading Regions');
    }
    try {
        final regions = await _repository.getDownloadedRegions();
        if (kDebugMode) {
          print('Loaded regions: $regions');
        }
         if (!mounted) {
            return;
        }
        state = state.copyWith(regions: regions);
    } on Exception catch (e) {
      if(kDebugMode) {
         print('Error loading regions: $e');
      }
      throw SettingsViewModelException('Error loading regions: $e');
    }

  }

  Future<void> clearData() async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(isLoading: true);
    if (kDebugMode) {
      print('Clearing cache');
    }
    try {
        await _repository.clearCache();
        await loadRegions();
        if (!mounted) {
          return;
        }
        state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
        if (kDebugMode) {
            print('Error clearing data: $e');
        }
         throw SettingsViewModelException('Error clearing data: $e');
    }

  }

  Future<void> clearSystemCache(BuildContext context) async {
    if (kIsWeb) {
      return;
    }
    if (Theme.of(context).platform == TargetPlatform.android) {
      await _openAppSettings();
    } else {
      _showDialog(context);
    }
  }

  Future<void> _openAppSettings() async {
     try {
        final intent = AndroidIntent(
          action: 'action_application_details_settings',
          data: Uri(scheme: 'package', path: 'YOUR_PACKAGE_NAME').toString(),
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } on Exception catch (e) {
        if (kDebugMode) {
          print('Could not open settings using AndroidIntent: $e');
        }
        await geo.Geolocator.openAppSettings();
      }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear System Cache'),
        content: const Text(
          'To clear the system cache, please go to your device settings, select this app, and clear its cache manually.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteRegion(String regionId) async {
     try {
        await _repository.deleteRegion(regionId);
        await loadRegions();
     } on Exception catch (e) {
        if (kDebugMode) {
             print('Error deleting region: $e');
        }
         throw SettingsViewModelException('Error deleting region: $e');
     }

  }

  @override
  void dispose() {
    _tileManagerService.dispose();
    super.dispose();
  }
}