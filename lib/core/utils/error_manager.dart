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

  void setError(String message) {
    state = state.copyWith(message: message);
  }

  void clearError() {
    state = state.copyWith();
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, ErrorState>(
  (ref) => ErrorNotifier(),
);
