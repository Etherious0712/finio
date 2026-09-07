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

  /// Strings come from the caller: this runs where a BuildContext is live, so
  /// the alert follows the app language instead of being hardcoded.
  static Future<void> checkAndNotify({
    required double expense,
    required double? budget,
    required String title,
    required String nearBody,
    required String overBody,
  }) async {
    if (budget == null || budget <= 0) return;
    final ratio = expense / budget;
    if (ratio >= 1.0) {
      await _show(id: 2, title: title, body: overBody);
    } else if (ratio >= 0.8) {
      await _show(id: 1, title: title, body: nearBody);
    }
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'budget_alert',
      // Channel name/description surface in Android system settings, which the
      // app can't localize from here — English is the least-bad default.
      'Budget alerts',
      channelDescription: 'Finio budget threshold alerts',
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
