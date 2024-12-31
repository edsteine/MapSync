///
/// File: lib/features/settings/settings_viewmodel.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages the state and logic for the settings screen, handling theme changes, data clearing, and region management.
/// Updates: Initial setup with theme change functionality, data clearing, loading regions, and Android-specific settings opening.
/// Used Libraries: android_intent_plus/android_intent.dart, android_intent_plus/flag.dart, flutter/foundation.dart, flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, geolocator/geolocator.dart, mobile/core/services/storage_service.dart, mobile/core/services/tile_service.dart, mobile/core/utils/app_constants.dart, mobile/features/settings/settings_repository.dart, mobile/main.dart
///
library;
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

// Custom exception for SettingsViewModel errors.
class SettingsViewModelException implements Exception {
  SettingsViewModelException(this.message, this.error);
  final String message;
  final dynamic error;

  @override
  String toString() => 'SettingsViewModelException: $message, $error';
}

/// Represents the state of the settings view model.
class SettingsState {
   /// Constructor of the state class, sets the default values
  SettingsState({
    this.themeMode = ThemeMode.light,
    this.regions = const [],
    this.isLoading = false,
    this.message, // Add message for callbacks
  });
    /// Current selected theme mode.
  final ThemeMode themeMode;
  /// List of downloaded regions.
  final List<String> regions;
  /// Loading status.
  final bool isLoading;
    /// Message for feedback after completing an action or when an error occur.
  final String? message; // Add message for callbacks

  /// Creates a copy of the state with optional new properties.
  SettingsState copyWith({
    ThemeMode? themeMode,
    List<String>? regions,
    bool? isLoading,
    String? message,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        regions: regions ?? this.regions,
        isLoading: isLoading ?? this.isLoading,
        message: message,
      );
}

/// Provider for the SettingsViewModel to manage state and logic for the settings screen.
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  final storageAsyncValue = ref.watch(storageProvider); // watch the AsyncValue
  // Handle the AsyncValue
  final storage = storageAsyncValue.when(
    data: (data) {
       // Prints a message in debug mode when the storage is loaded successfully
      if (kDebugMode) {
        print('SettingsViewModel: Storage loaded successfully');
      }
      return data;
    },
    error: (error, stack) {
       // Prints an error message with the stack trace to the console in debug mode.
      if (kDebugMode) {
        print(
          'SettingsViewModel: Error loading storage: $error, Stacktrace: $stack',
        );
      }
       // Throws a custom exception for error during the storage loading.
      throw SettingsViewModelException('Error loading storage', error);
    },
    loading: () {
        // Prints a message to the console when storage is loading.
      if (kDebugMode) {
        print('SettingsViewModel: Loading storage...');
      }
       // returns a default value during the loading.
      return null;
    },
  );

   // Return default view model if the storage is null.
  if (storage == null) {
      // Prints to the console when storage is null.
    if (kDebugMode) {
      print('SettingsViewModel: Storage is null, using default view model');
    }
      // Creates a SettingsViewModel with a default storage and other required instances
    return SettingsViewModel(
      ref.watch(settingsRepositoryProvider),
      ref.watch(tileServiceProvider),
      Future.value(Storage()),
      ref.watch(themeModeProvider.notifier),
      ref,
    );
  }
   // Creates a SettingsViewModel with the loaded storage and other required instances.
  return SettingsViewModel(
    ref.watch(settingsRepositoryProvider),
    ref.watch(tileServiceProvider),
    Future.value(storage),
    ref.watch(themeModeProvider.notifier),
    ref,
  );
});

/// SettingsViewModel manages the state and business logic for the settings screen.
class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(
    this._repository,
    this._tileManagerService,
    this._storage,
    this._themeModeNotifier,
    this.ref,
  ) : super(SettingsState()) {
    // Executes after the storage is initialized, and loads the regions
    _storage.then((value) {
        // Checks if value is not null before trying to load the regions.
      // ignore: unnecessary_null_comparison
      if (value != null) {
        loadRegions();
      }
       //Prints to console if storage is not null.
      if (kDebugMode) {
        print('SettingsViewModel: Storage is not null, loading regions');
      }
    });
  }
  /// Settings repository instance for data operations
  final SettingsRepository _repository;
  ///  Tile service manager for managing tile storage operations.
  final TileService _tileManagerService;
  /// Controller for theme mode state.
  final StateController<ThemeMode> _themeModeNotifier;
  /// Future storage instance to retrieve from database.
  late final Future<Storage> _storage;
   /// Riverpod ref to update the state.
  final Ref ref;

    /// Changes the theme, saves the change to storage and updates the state.
  Future<void> changeTheme(ThemeMode themeMode) async {
    // Prints to the console in debug mode when the theme change starts.
    if (kDebugMode) {
      print(
        'SettingsViewModel: Attempting to change theme to: ${themeMode.name}',
      );
    }
    // returns when the state is not mounted.
    if (!mounted) {
      return;
    }
    // Set the new state of theme.
    _themeModeNotifier.state = themeMode;

    // Gets an instance of storage.
    final storage = await _storage;
     //Prints to the console in debug mode when the theme is being saved to storage
    if (kDebugMode) {
      print('SettingsViewModel: Saving theme to storage: ${themeMode.name}');
    }
    // Saves the theme to storage
    await storage.saveString(AppConstants.themeModeKey, themeMode.name);
     //Prints to the console in debug mode after the theme is saved to the storage.
    if (kDebugMode) {
      print('SettingsViewModel: Saved theme to storage: ${themeMode.name}');
    }
      // Prints to the console when theme changes and the state is set.
    if (kDebugMode) {
      print(
        'SettingsViewModel: Theme changed to: ${themeMode.name} setting state',
      );
    }
    // Set the new state for the view model.
    state = state.copyWith(themeMode: themeMode);
  }

    /// Loads the downloaded regions from repository and updates the state.
  Future<void> loadRegions() async {
      // Prints to the console in debug mode when the regions are being loaded.
    if (kDebugMode) {
      print('Loading Regions');
    }
    try {
        // Retrieves the downloaded regions using the repository.
      final regions = await _repository.getDownloadedRegions();
      // Prints the downloaded regions to the console.
      if (kDebugMode) {
        print('Loaded regions: $regions');
      }
      // returns when the state is not mounted.
      if (!mounted) {
        return;
      }
      // Updates the state with the new region.
      state = state.copyWith(regions: regions);
      // Catches any exception that occurs when loading the regions.
    } on Exception catch (e) {
        // Prints to the console the exception that occurred when loading regions
      if (kDebugMode) {
        print('Error loading regions: $e');
      }
       // Throws an exception with the error.
      throw SettingsViewModelException('Error loading regions', e);
    }
  }

   /// Clears application data (cache, markers), and reloads regions.
  Future<void> clearData(BuildContext context) async {
       // return if the state is not mounted.
    if (!mounted) {
      return;
    }
      // Updates the state to show loading.
    state = state.copyWith(isLoading: true);
     // Prints the console when the cache is about to get cleared
    if (kDebugMode) {
      print('Clearing cache');
    }
    try {
      // Clears the cache.
      await _repository.clearCache();
      // Reloads the regions after clearing the cache
      await loadRegions();
      // Returns when the state is not mounted
      if (!mounted) {
        return;
      }
       // Update the state to stop loading and to show a message to the user.
      state = state.copyWith(isLoading: false, message: 'Data cleared!');
        // Catches any exception that occurs when clearing data.
    } on Exception catch (e) {
       // Prints the error to console when the data failed to get cleared.
      if (kDebugMode) {
        print('Error clearing data: $e');
      }
       // Updates the state to stop loading and return error message.
      state =
          state.copyWith(isLoading: false, message: 'Error clearing data: $e');
          // Throws custom exception with the error message.
      throw SettingsViewModelException('Error clearing data', e);
    }
  }

    /// Opens the system app settings for the current application.
  Future<void> clearSystemCache(BuildContext context) async {
    // return if its a web platform
    if (kIsWeb) {
      return;
    }
     // Opens the app settings for android
    if (Theme.of(context).platform == TargetPlatform.android) {
      await _openAppSettings();
       // Shows a dialog on other platforms since there is no built in functionality
    } else {
      _showDialog(context);
    }
  }

  /// Opens the settings using AndroidIntent, it defaults to open settings using Geolocator if it fails.
  Future<void> _openAppSettings() async {
    try {
      // Using intent to launch settings for the current application
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
      // Opens settings using the geolocator package.
      await geo.Geolocator.openAppSettings();
    }
  }

    /// Shows a dialog for non-Android platforms to clear system cache manually.
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

    /// Deletes a specified region using the repository and reloads regions.
  Future<void> deleteRegion(String regionId) async {
    try {
         // Deletes a region using it's id
      await _repository.deleteRegion(regionId);
       // Reload the regions after deletion.
      await loadRegions();
        // Catches any exception that occurs during deleting the regions.
    } on Exception catch (e) {
        // Prints the error to the console if the deletion fails.
      if (kDebugMode) {
        print('Error deleting region: $e');
      }
       // Throws a custom exception if the deletion of the region failed.
      throw SettingsViewModelException('Error deleting region', e);
    }
  }

  @override
  void dispose() {
      // Disposes of the tile manager service when the view model is disposed of.
    _tileManagerService.dispose();
    super.dispose();
  }
}