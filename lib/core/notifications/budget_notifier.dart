import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BudgetNotifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  static Future<void> checkAndNotify({
    required double expense,
    required double? budget,
  }) async {
    if (budget == null || budget <= 0) return;
    final ratio = expense / budget;
    if (ratio >= 1.0) {
      await _show(
        id: 2,
        title: 'Finio 预算提醒',
        body: '本月支出已超出预算！',
      );
    } else if (ratio >= 0.8) {
      await _show(
        id: 1,
        title: 'Finio 预算提醒',
        body: '本月支出已达预算的 80%，请注意控制开支',
      );
    }
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'budget_alert',
      '预算提醒',
      channelDescription: 'Finio 预算超支提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}
