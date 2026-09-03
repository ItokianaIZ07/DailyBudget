import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _budgetChannel =
      AndroidNotificationChannel(
        'budget_alerts',
        'Alertes budgétaires',
        description: 'Notifications concernant les budgets et dépenses.',
        importance: Importance.high,
      );

  NotificationService._();

  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings: settings);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_budgetChannel);

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'budget_alerts',
          'Alertes budgétaires',
          channelDescription:
              'Notifications concernant les budgets et dépenses.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification'
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id: 0, title: title, body: body, notificationDetails: details);
  }
}
