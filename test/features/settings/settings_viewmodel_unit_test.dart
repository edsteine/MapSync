// test/features/settings/settings_viewmodel_unit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/services/tile_service.dart';
import 'package:mobile/features/settings/settings_repository.dart';
import 'package:mobile/features/settings/settings_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/utils/app_utils_unit_test.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockTileService extends Mock implements TileService {}

class MockStorage extends Mock implements Storage {}

class MockStateController extends Mock implements StateController<ThemeMode> {}

class MockRef extends Mock implements Ref<SettingsState> {}

void main() {
  group('settings_viewmodel_unit_test', () {
    late SettingsViewModel settingsViewModel;
    late MockSettingsRepository mockSettingsRepository;
    late MockTileService mockTileService;
    late MockStorage mockStorage;
    late MockStateController mockThemeModeController;
    late MockRef mockRef;
    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      mockTileService = MockTileService();
      mockStorage = MockStorage();
      mockThemeModeController = MockStateController();
      mockRef = MockRef<SettingsState>();

      when(() => mockStorage.saveString(any(), any())).thenAnswer((_) async {});
      settingsViewModel = SettingsViewModel(
        mockSettingsRepository,
        mockTileService,
        Future.value(mockStorage),
        mockThemeModeController,
        mockRef,
      );
      registerFallbackValue(SettingsState());
    });
    test('changeTheme success', () async {
      when(() => mockThemeModeController.state = any()).thenAnswer((_) {});

      await settingsViewModel.changeTheme(ThemeMode.dark);
      verify(() => mockStorage.saveString(any(), any())).called(1);
      expect(settingsViewModel.state.themeMode, ThemeMode.dark);
    });

    test('loadRegions success', () async {
      when(() => mockSettingsRepository.getDownloadedRegions())
          .thenAnswer((_) async => ['test']);
      await settingsViewModel.loadRegions();
      expect(settingsViewModel.state.regions, ['test']);
    });

    test('loadRegions failure', () async {
      when(() => mockSettingsRepository.getDownloadedRegions())
          .thenThrow(Exception('test'));
      expect(
        () async => settingsViewModel.loadRegions(),
        throwsA(isA<SettingsViewModelException>()),
      );
    });
    test('clearData success', () async {
      when(() => mockSettingsRepository.clearCache()).thenAnswer((_) async {});
      when(() => mockSettingsRepository.getDownloadedRegions())
          .thenAnswer((_) async => []);
      await settingsViewModel.clearData(MockBuildContext());
      expect(settingsViewModel.state.isLoading, false);
    });
    test('clearData failure', () async {
      when(() => mockSettingsRepository.clearCache())
          .thenThrow(Exception('test'));
      expect(
        () async => settingsViewModel.clearData(MockBuildContext()),
        throwsA(isA<SettingsViewModelException>()),
      );
    });
    test('deleteRegion success', () async {
      when(() => mockSettingsRepository.deleteRegion(any()))
          .thenAnswer((_) async {});
      when(() => mockSettingsRepository.getDownloadedRegions())
          .thenAnswer((_) async => []);

      await settingsViewModel.deleteRegion('test');

      verify(() => mockSettingsRepository.deleteRegion(any())).called(1);
    });
    test('deleteRegion failure', () async {
      when(() => mockSettingsRepository.deleteRegion(any()))
          .thenThrow(Exception('test'));
      expect(
        () async => settingsViewModel.deleteRegion('test'),
        throwsA(isA<SettingsViewModelException>()),
      );
    });
  });
}
