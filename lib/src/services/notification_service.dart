import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> notifyScheduled({
    required String caption,
    required DateTime scheduledAt,
  }) async {
    await init();
    final fmt = DateFormat('EEE d MMM à HH:mm');
    await _plugin.show(
      scheduledAt.millisecondsSinceEpoch ~/ 1000,
      'Post planifié',
      'Publication prévue le ${fmt.format(scheduledAt.toLocal())}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_posts',
          'Posts planifiés',
          channelDescription: 'Confirmations de posts planifiés',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static Future<void> notifyPublished(String caption) async {
    await init();
    final preview = caption.length > 80 ? '${caption.substring(0, 80)}…' : caption;
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Post publié !',
      preview.isEmpty ? 'Votre post a été publié avec succès.' : preview,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'published_posts',
          'Posts publiés',
          channelDescription: 'Notifications de publication réussie',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
