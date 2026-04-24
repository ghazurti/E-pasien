import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM on Android
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'epasien_channel',
    'Notifikasi E-Pasien',
    description: 'Notifikasi dari aplikasi SiSehat Bau-Bau',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications for foreground
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotif.initialize(initSettings);

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  Future<void> registerTokenToBackend() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      final authToken = await StorageService().getToken();
      if (authToken == null) return;

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/fcm/token'),
        headers: ApiConfig.headers(token: authToken),
        body: jsonEncode({'token': token, 'platform': 'android'}),
      );
    } catch (_) {}
  }
}
