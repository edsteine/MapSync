///
/// File: lib/core/services/download_manager_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages the state of downloads.
/// Updates: Initial setup for managing download states like isDownloading and progress.
/// Used Libraries: flutter_riverpod/flutter_riverpod.dart
///
library;
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class DownloadState {
//   DownloadState({this.isDownloading = false, this.progress = 0.0, this.error});
//   final bool isDownloading;
//   final double progress;
//   final String? error;

//   DownloadState copyWith({
//     bool? isDownloading,
//     double? progress,
//     String? error,
//   }) =>
//       DownloadState(
//         isDownloading: isDownloading ?? this.isDownloading,
//         progress: progress ?? this.progress,
//         error: error ?? this.error,
//       );
// }

// class DownloadManager extends StateNotifier<DownloadState> {
//   DownloadManager() : super(DownloadState());

//   void startDownload() {
//     state = state.copyWith(isDownloading: true, progress: 0);
//   }

//   void updateProgress(double progress) {
//     state = state.copyWith(progress: progress);
//   }

//   void finishDownload() {
//     state = state.copyWith(isDownloading: false, progress: 1);
//   }

//   void setError(String error) {
//     state = state.copyWith(isDownloading: false, error: error);
//   }

//   void clearError() {
//     state = state.copyWith();
//   }
// }

// final downloadManagerProvider =
//     StateNotifierProvider<DownloadManager, DownloadState>(
//   (ref) => DownloadManager(),
// );