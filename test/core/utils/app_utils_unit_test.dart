// test/core/utils/app_utils_unit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/core/utils/app_utils.dart';
import 'package:mocktail/mocktail.dart';

class MockStateNotifier<T> extends Mock implements StateNotifier<T> {}

class MockRef<S> extends Mock implements Ref<S> {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('app_utils_unit_test', () {
    test('formatFileSize', () {
      expect(AppUtils.formatFileSize(0), '0 B');
      expect(AppUtils.formatFileSize(1023), '1023.00 B');
      expect(AppUtils.formatFileSize(1024), '1.00 KB');
      expect(AppUtils.formatFileSize(1500), '1.46 KB');
      expect(AppUtils.formatFileSize(1048576), '1.00 MB');
    });

    test('handleStateError with context', () {
      final mockNotifier = MockStateNotifier<dynamic>();
      final mockRef = MockRef<dynamic>();
      final mockContext = MockBuildContext();
      registerFallbackValue(StateController(DownloadStatus.idle));
      when(() => mockNotifier.mounted).thenReturn(true);
      when(() => mockRef.read(any())).thenReturn(mockContext);
      when(() => ScaffoldMessenger.of(mockContext))
          .thenReturn(ScaffoldMessengerState());
      when(
        () => (mockNotifier.state as dynamic).copyWith(
          downloadStatus: any(named: 'downloadStatus'),
          error: any(named: 'error'),
        ),
      ).thenReturn(StateController(DownloadStatus.idle));
      AppUtils.handleStateError(
        mockNotifier,
        mockRef,
        StateController(DownloadStatus.idle),
        'error',
        'error message',
      );

      verify(
        () => (mockNotifier.state as dynamic).copyWith(
          downloadStatus: any(named: 'downloadStatus'),
          error: any(named: 'error'),
        ),
      ).called(1);
      verify(() => mockRef.read(any())).called(1);
    });
    test('handleStateError no context', () {
      final mockNotifier = MockStateNotifier<dynamic>();
      final mockRef = MockRef<dynamic>();
      registerFallbackValue(StateController(DownloadStatus.idle));

      when(() => mockNotifier.mounted).thenReturn(true);
      when(() => mockRef.read(any())).thenReturn(null);
      when(
        () => (mockNotifier.state as dynamic).copyWith(
          downloadStatus: any(named: 'downloadStatus'),
          error: any(named: 'error'),
        ),
      ).thenReturn(StateController(DownloadStatus.idle));
      AppUtils.handleStateError(
        mockNotifier,
        mockRef,
        StateController(DownloadStatus.idle),
        'error',
        'error message',
      );

      verify(
        () => (mockNotifier.state as dynamic).copyWith(
          downloadStatus: any(named: 'downloadStatus'),
          error: any(named: 'error'),
        ),
      ).called(1);
      verifyNever(() => mockRef.read(any()));
    });
    test('handleStateError not mounted', () {
      final mockNotifier = MockStateNotifier<dynamic>();
      final mockRef = MockRef<dynamic>();
      registerFallbackValue(StateController(DownloadStatus.idle));

      when(() => mockNotifier.mounted).thenReturn(false);
      AppUtils.handleStateError(
        mockNotifier,
        mockRef,
        StateController(DownloadStatus.idle),
        'error',
        'error message',
      );
      verifyNever(
        () => (mockNotifier.state as dynamic).copyWith(
          downloadStatus: any(named: 'downloadStatus'),
          error: any(named: 'error'),
        ),
      );
      verifyNever(() => mockRef.read(any()));
    });
  });
}
