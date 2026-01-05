import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  String? _fcmToken;

  NotificationService._internal();

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    await requestPermission();

    // Get and save FCM token
    await _getFcmToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check if app was opened from a terminated state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get FCM token
  Future<String?> _getFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Save token to backend if user is authenticated
      if (_fcmToken != null) {
        await _saveFcmTokenToBackend(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    _fcmToken = token;
    if (kDebugMode) {
      print('FCM Token refreshed: $token');
    }
    _saveFcmTokenToBackend(token);
  }

  /// Save FCM token to backend
  Future<void> _saveFcmTokenToBackend(String token) async {
    try {
      final accessToken = await _storage.getAccessToken();
      if (accessToken == null) return; // Not logged in

      await _api.post('/api/auth/fcm-token', data: {'fcm_token': token});
      if (kDebugMode) {
        print('FCM token saved to backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // You can show a local notification here or update the UI
    // For now, we'll just log it
  }

  /// Handle when app is opened from notification
  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened from notification: ${message.messageId}');
    }
    _handleNotificationTap(message);
  }

  /// Handle notification tap - navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    // Navigate based on notification type
    if (data.containsKey('novel_id')) {
      // Navigate to novel detail
      // Navigator.pushNamed(context, '/novel', arguments: data['novel_id']);
    } else if (data.containsKey('chapter_id')) {
      // Navigate to reader
      // Navigator.pushNamed(context, '/reader', arguments: {...});
    }
  }

  /// Subscribe to a topic (e.g., for novel updates)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;
}
