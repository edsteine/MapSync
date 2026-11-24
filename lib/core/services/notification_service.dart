///
/// File: lib/core/services/notification_service.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Manages local notifications for the application.
/// Updates: Initial setup with initialization, showing notifications, progress notifications, and canceling notifications.
/// Used Libraries: flutter/foundation.dart, flutter_local_notifications/flutter_local_notifications.dart, mobile/core/utils/app_constants.dart
///
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/utils/app_constants.dart';

//  NotificationService class provides static methods for managing app notifications.
// ignore: avoid_classes_with_only_static_members
class NotificationService {
  /// Plugin for managing local notifications.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
    /// Action identifier for pausing a download.
  static const String downloadPauseActionId = 'download_pause_action';
    /// Action identifier for canceling a download.
  static const String downloadCancelActionId = 'download_cancel_action';

    /// Initializes the notification service by setting up platform-specific configurations.
  static Future<void> init() async {
      // Android specific notification initialization settings.
    const initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
     // Darwin (iOS and macOS) specific notification initialization settings.
    const initializationSettingsDarwin = DarwinInitializationSettings(
        // Request specific permissions, if necessary for your app
        );

     // Combines initialization settings for all platforms.
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
     // Initializes the notification plugin.
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

   /// Handles actions on notification tap
  static Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
     // Prints the notification response to the console in debug mode.
    if (kDebugMode) {
      print('Notification response: $notificationResponse');
    }
     //Handles the case when download is paused
    if (notificationResponse.actionId == downloadPauseActionId) {
      // Pause the current action, we are not going to do anything here. The action will be handled in the MapService
       // Prints a message to the console when download is paused.
      if (kDebugMode) {
        print('Download is paused!');
      }
    } else if (notificationResponse.actionId == downloadCancelActionId) {
       // Cancel the current action, we are not going to do anything here. The action will be handled in the MapService
       // Prints a message to the console when download is canceled.
      if (kDebugMode) {
        print('Download is canceled!');
      }
    }
  }

   /// Displays a simple notification with title and body.
  static Future<void> showNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    // Android specific notification details.
    const androidNotificationDetails = AndroidNotificationDetails(
      AppConstants.channelId,
      AppConstants.channelName,
      channelDescription: AppConstants.channelDescription,
      priority: Priority.max,
      importance: Importance.max,
      showWhen: false,
    );
    // Combine the platform notification details.
    const notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    // Shows the notification
    await flutterLocalNotificationsPlugin.show(
      id ?? 0,
      title,
      body,
      notificationDetails,
    );
  }

    /// Displays a progress notification with a title and a progress value.
  static Future<void> showProgressNotification({
    required String title,
    required int progress,
    int? id,
    bool indeterminate = false,
  }) async {
    // Android specific notification details
    final androidNotificationDetails = AndroidNotificationDetails(
      AppConstants.channelId,
      AppConstants.channelName,
      channelDescription: AppConstants.channelDescription,
      priority: Priority.min,
      importance: Importance.min,
      showWhen: false,
      progress: progress,
      maxProgress: 100,
      indeterminate: indeterminate,
      ongoing: true,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(downloadPauseActionId, 'Pause'),
        AndroidNotificationAction(downloadCancelActionId, 'Cancel'),
      ],
    );
      // Combine the platform notification details
    final notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    // Shows the progress notification
    await flutterLocalNotificationsPlugin.show(
      id ?? 1,
      title,
      '$progress%',
      notificationDetails,
    );
  }

    /// Cancels a specific notification by its ID.
  static Future<void> cancelNotification(int id) async {
     // Cancels the notification with the given id
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}