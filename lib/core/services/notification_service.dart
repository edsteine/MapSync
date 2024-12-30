// lib/core/services/notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/utils/app_constants.dart';

// ignore: avoid_classes_with_only_static_members
class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String downloadPauseActionId = 'download_pause_action';
  static const String downloadCancelActionId = 'download_cancel_action';

  static Future<void> init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const initializationSettingsDarwin = DarwinInitializationSettings(
        // Request specific permissions, if necessary for your app
        );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  static Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    if (kDebugMode) {
      print('Notification response: $notificationResponse');
    }
    if (notificationResponse.actionId == downloadPauseActionId) {
      // Pause the current action, we are not going to do anything here. The action will be handled in the MapService
      if (kDebugMode) {
        print('Download is paused!');
      }
    } else if (notificationResponse.actionId == downloadCancelActionId) {
      // Cancel the current action, we are not going to do anything here. The action will be handled in the MapService
      if (kDebugMode) {
        print('Download is canceled!');
      }
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      AppConstants.channelId,
      AppConstants.channelName,
      channelDescription: AppConstants.channelDescription,
      priority: Priority.max,
      importance: Importance.max,
      showWhen: false,
    );
    const notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      id ?? 0,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showProgressNotification({
    required String title,
    required int progress,
    int? id,
    bool indeterminate = false,
  }) async {
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
    final notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      id ?? 1,
      title,
      '$progress%',
      notificationDetails,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}