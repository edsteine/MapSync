// lib/core/utils/error_manager.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorState {
  ErrorState({this.message});
  final String? message;

  ErrorState copyWith({String? message}) =>
      ErrorState(message: message ?? this.message);
}

class ErrorNotifier extends StateNotifier<ErrorState> {
  ErrorNotifier() : super(ErrorState());

  set mapState(ErrorState newState) {
    state = newState;
  }

  ErrorState get mapState => state;

  // void updateState(ErrorState newState) {
  //   state = newState;
  // }

  void setError(String message) {
    // updateState(state.copyWith(message: message));
    state.copyWith(message: message);
  }

  void clearError() {
    // updateState(state.copyWith());
    state.copyWith();
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, ErrorState>(
  (ref) => ErrorNotifier(),
);
