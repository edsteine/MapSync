// test/core/services/notification_service_unit_test.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  group('notification_service_unit_test', () {
    late NotificationService notificationService;
    late MockFlutterLocalNotificationsPlugin mockPlugin;

    setUp(() async {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).thenAnswer((_) async => true);
      notificationService = NotificationService();

      await NotificationService.init();
    });
    test('init success', () async {
      verify(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).called(1);
    });

    test('showNotification success', () async {
      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});
      await NotificationService.showNotification(title: 'test', body: 'test');
      verify(() => mockPlugin.show(any(), any(), any(), any())).called(1);
    });
    test('showProgressNotification success', () async {
      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      await NotificationService.showProgressNotification(
        title: 'test',
        progress: 50,
      );

      verify(() => mockPlugin.show(any(), any(), any(), any())).called(1);
    });
    test('cancelNotification success', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

      await NotificationService.cancelNotification(1);
      verify(() => mockPlugin.cancel(any())).called(1);
    });
  });
}
