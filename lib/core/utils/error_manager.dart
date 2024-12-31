///
/// File: lib/core/utils/error_manager.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Provides a state management solution for handling errors in the application.
/// Updates: Initial setup for error state and notifier.
/// Used Libraries: flutter_riverpod/flutter_riverpod.dart
///
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the state of an error in the application.
class ErrorState {
  ErrorState({this.message});
  /// Message of the error.
  final String? message;

  ///  Creates a copy of the ErrorState with an optional updated message.
  ErrorState copyWith({String? message}) =>
      ErrorState(message: message ?? this.message);
}

/// Manages the state of errors, providing methods to set and clear errors.
class ErrorNotifier extends StateNotifier<ErrorState> {
  ErrorNotifier() : super(ErrorState());

  set mapState(ErrorState newState) {
    state = newState;
  }

  ErrorState get mapState => state;

  // void updateState(ErrorState newState) {
  //   state = newState;
  // }
  /// Sets a new error message.
  void setError(String message) {
    // updateState(state.copyWith(message: message));
    state.copyWith(message: message);
  }

    /// Clears the current error message.
  void clearError() {
    // updateState(state.copyWith());
    state.copyWith();
  }
}

/// Provider for the ErrorNotifier to manage error state throughout the app.
final errorProvider = StateNotifierProvider<ErrorNotifier, ErrorState>(
  (ref) => ErrorNotifier(),
);