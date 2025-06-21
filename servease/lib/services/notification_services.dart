import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications(String userId) async {
    print("🔔 Initializing notifications for user: $userId");

    // Request permission first
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User declined or has not accepted permission');
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      print("📱 FCM Token: $token");
      await sendTokenToBackend(userId, token);
    } else {
      print("❌ Failed to get FCM token");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground notification received:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 App opened from notification');
      final bookingId = message.data['bookingId'];
      if (bookingId != null) {
        print("Navigate to Booking ID: $bookingId");
        // Navigate to booking details screen here
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'servease_channel',
      'ServEase Notifications',
      channelDescription: 'Notifications for ServEase app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  Future<void> sendTokenToBackend(String userId, String token) async {
    final String backendUrl = '${ApiConfig.baseUrl}/api/notification/save-token';

    print("📤 Sending token to backend...");
    print("User ID: $userId");
    print("Token: $token");

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcmToken': token,
        }),
      );

      print("📡 Backend response status: ${response.statusCode}");
      print("📡 Backend response body: ${response.body}");

      if (response.statusCode == 200) {
        print('✅ Token sent successfully');
      } else {
        print('❌ Failed to send token: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending token: $e');
    }
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background notification received:');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}
