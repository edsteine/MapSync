// test/core/utils/error_manager_unit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/error_manager.dart';

void main() {
  group('error_manager_unit_test', () {
    test('setError', () {
      final errorNotifier = ErrorNotifier();
      errorNotifier.setError('test error');
      expect(errorNotifier.mapState.message, 'test error');
    });

    test('clearError', () {
      final errorNotifier = ErrorNotifier();
      errorNotifier.setError('test error');
      errorNotifier.clearError();
      expect(errorNotifier.mapState.message, null);
    });
    test('copyWith', () {
      final errorState = ErrorState(message: 'test error');
      final newState = errorState.copyWith(message: 'new error');
      expect(newState.message, 'new error');
      final newStateNull = errorState.copyWith();
      expect(newStateNull.message, 'test error');
    });
  });
}
