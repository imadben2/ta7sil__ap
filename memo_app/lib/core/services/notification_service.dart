import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[NotificationService] Background message: ${message.messageId}');
}

/// Service for managing push notifications via Firebase Cloud Messaging
/// and local notifications display
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Stream controller for notification events
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of notification events for app to listen to
  Stream<Map<String, dynamic>> get onNotification =>
      _notificationController.stream;

  /// Current FCM token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Permission status
  bool _permissionsGranted = false;
  bool get permissionsGranted => _permissionsGranted;

  /// Stream controller for token refresh
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  /// Android notification channel for high importance notifications (FCM)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'memo_bac_notifications',
    'MEMO BAC Notifications',
    description: 'Notifications for MEMO BAC educational app',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Android notification channel for session reminders (scheduled)
  static const AndroidNotificationChannel _sessionReminderChannel =
      AndroidNotificationChannel(
    'session_reminders',
    'تذكيرات الجلسات',
    description: 'إشعارات قبل بداية الجلسات الدراسية',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Android notification channel for general local notifications
  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'memo_notifications',
    'إشعارات ميمو',
    description: 'إشعارات تطبيق ميمو التعليمي',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the notification service
  Future<void> init() async {
    try {
      // Initialize Firebase Messaging instance
      _messaging = FirebaseMessaging.instance;

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initLocalNotifications();

      // Create notification channels for Android
      if (Platform.isAndroid) {
        final androidImpl = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.createNotificationChannel(_channel);
        await androidImpl?.createNotificationChannel(_sessionReminderChannel);
        await androidImpl?.createNotificationChannel(_generalChannel);
        debugPrint('[NotificationService] Android notification channels created');

        // Request exact alarm permission for Android 12+ (API 31+)
        await _requestExactAlarmPermission();

        // Request notification permission for Android 13+ (API 33+)
        await _requestAndroidNotificationPermission();
      }

      // Request notification permission
      _permissionsGranted = await requestPermission();
      debugPrint('[NotificationService] Permissions granted: $_permissionsGranted');

      // Get initial FCM token
      _fcmToken = await _messaging?.getToken();
      debugPrint('[NotificationService] FCM Token: ${_fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : 'null'}');

      if (_fcmToken == null) {
        debugPrint('[NotificationService] WARNING: FCM token is null - push notifications will not work');
      }

      // Listen for token refresh
      _messaging?.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _tokenRefreshController.add(token);
        debugPrint('[NotificationService] Token refreshed: $token');
      });

      // Setup message handlers
      _setupMessageHandlers();

      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }
  }

  /// Request exact alarm permission for Android 12+ (API 31+)
  /// Required for scheduled notifications with exact timing
  Future<void> _requestExactAlarmPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.scheduleExactAlarm.status;
        debugPrint('[NotificationService] Exact alarm permission status: $status');

        if (status.isDenied) {
          final result = await Permission.scheduleExactAlarm.request();
          debugPrint('[NotificationService] Exact alarm permission result: $result');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Exact alarm permission error: $e');
    }
  }

  /// Request notification permission for Android 13+ (API 33+)
  /// Required for showing any notifications on Android 13 and above
  Future<void> _requestAndroidNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        debugPrint('[NotificationService] Notification permission status: $status');

        if (status.isDenied) {
          final result = await Permission.notification.request();
          debugPrint('[NotificationService] Notification permission result: $result');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Notification permission error: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _notificationController.add({
          'type': 'tap',
          'data': data,
        });
      } catch (e) {
        debugPrint('[NotificationService] Error parsing payload: $e');
      }
    }
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Background notification tapped: ${response.payload}');
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Foreground message: ${message.messageId}');
      _handleMessage(message, inForeground: true);
    });

    // Handle message opened app (from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Opened from background: ${message.messageId}');
      _handleMessageOpen(message);
    });

    // Check for initial message (app opened from terminated)
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    if (_messaging == null) return;

    final message = await _messaging!.getInitialMessage();
    if (message != null) {
      debugPrint('[NotificationService] Initial message: ${message.messageId}');
      _handleMessageOpen(message);
    }
  }

  /// Handle incoming message
  void _handleMessage(RemoteMessage message, {bool inForeground = false}) {
    final notification = message.notification;
    final data = message.data;

    // Emit event for in-app handling
    _notificationController.add({
      'type': 'received',
      'inForeground': inForeground,
      'title': notification?.title,
      'body': notification?.body,
      'data': data,
    });

    // Show local notification if in foreground
    if (inForeground && notification != null) {
      showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        data: data,
      );
    }
  }

  /// Handle message that opened the app
  void _handleMessageOpen(RemoteMessage message) {
    _notificationController.add({
      'type': 'open',
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      if (_messaging == null) {
        debugPrint('[NotificationService] Firebase Messaging not initialized');
        return false;
      }

      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final authorized = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('[NotificationService] Permission: ${settings.authorizationStatus}');
      return authorized;
    } catch (e) {
      debugPrint('[NotificationService] Permission error: $e');
      return false;
    }
  }

  /// Show a local notification (public for testing purposes)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int? id,
  }) async {
    // Add RLM (Right-to-Left Mark) to force RTL alignment on each line
    const rlm = '\u200F';
    // Add RLM at start of title and each line in body
    final rtlTitle = '$rlm$title';
    final rtlBody = body.split('\n').map((line) => '$rlm$line').join('\n');

    // Use BigTextStyleInformation for proper RTL Arabic text alignment
    final androidDetails = AndroidNotificationDetails(
      'memo_notifications',
      'إشعارات ميمو',
      channelDescription: 'إشعارات تطبيق ميمو التعليمي',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        rtlBody,
        contentTitle: rtlTitle,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        rtlTitle,
        rtlBody,
        details,
        payload: data != null ? jsonEncode(data) : null,
      );
      debugPrint('[NotificationService] Local notification shown: $title');
    } catch (e) {
      debugPrint('[NotificationService] Error showing local notification: $e');
    }
  }

  /// Test local notification - for debugging purposes
  Future<void> testLocalNotification() async {
    debugPrint('[NotificationService] Testing local notification...');
    await showLocalNotification(
      title: 'اختبار الإشعارات',
      body: 'هذا إشعار تجريبي للتأكد من عمل النظام',
      data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidImpl?.areNotificationsEnabled() ?? false;
        debugPrint('[NotificationService] Notifications enabled: $enabled');
        return enabled;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Error checking notification status: $e');
      return false;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (_messaging == null) {
        debugPrint('[NotificationService] Firebase Messaging not initialized');
        return;
      }
      await _messaging!.subscribeToTopic(topic);
      debugPrint('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Subscribe error: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_messaging == null) {
        debugPrint('[NotificationService] Firebase Messaging not initialized');
        return;
      }
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Unsubscribe error: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    if (_messaging == null) {
      debugPrint('[NotificationService] Firebase Messaging not initialized');
      return null;
    }
    _fcmToken = await _messaging!.getToken();
    return _fcmToken;
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      if (_messaging == null) {
        debugPrint('[NotificationService] Firebase Messaging not initialized');
        return;
      }
      await _messaging!.deleteToken();
      _fcmToken = null;
      debugPrint('[NotificationService] Token deleted');
    } catch (e) {
      debugPrint('[NotificationService] Delete token error: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ===== LOCAL SCHEDULED NOTIFICATION METHODS =====

  /// Initialize local notifications for scheduled notifications
  Future<void> initializeLocalNotifications() async {
    // Already initialized in _initLocalNotifications during init()
    debugPrint('[NotificationService] Local notifications initialized');
  }

  /// Schedule a local notification at a specific time
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      final androidDetails = AndroidNotificationDetails(
        _sessionReminderChannel.id,
        _sessionReminderChannel.name,
        channelDescription: _sessionReminderChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode(payload),
      );

      debugPrint(
          '[NotificationService] Scheduled notification $id for $scheduledTime');
    } catch (e) {
      debugPrint('[NotificationService] Schedule error: $e');
    }
  }

  /// Cancel a specific local notification by ID
  Future<void> cancelLocalNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      debugPrint('[NotificationService] Cancelled notification $id');
    } catch (e) {
      debugPrint('[NotificationService] Cancel error: $e');
    }
  }

  /// Cancel all local scheduled notifications
  Future<void> cancelAllLocalNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('[NotificationService] Cancelled all notifications');
    } catch (e) {
      debugPrint('[NotificationService] Cancel all error: $e');
    }
  }

  /// Get notification app launch details (for deep linking)
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    try {
      return await _localNotifications.getNotificationAppLaunchDetails();
    } catch (e) {
      debugPrint('[NotificationService] Get launch details error: $e');
      return null;
    }
  }

  /// Get list of pending scheduled notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _localNotifications.pendingNotificationRequests();
      debugPrint('[NotificationService] Pending notifications: ${pending.length}');
      for (final notification in pending) {
        debugPrint('[NotificationService] - ID: ${notification.id}, Title: ${notification.title}');
      }
      return pending;
    } catch (e) {
      debugPrint('[NotificationService] Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notification system is fully initialized and working
  Future<Map<String, dynamic>> getNotificationStatus() async {
    final pending = await getPendingNotifications();
    final notificationsEnabled = await areNotificationsEnabled();

    return {
      'fcmToken': _fcmToken != null,
      'fcmTokenValue': _fcmToken,
      'permissionsGranted': _permissionsGranted,
      'notificationsEnabled': notificationsEnabled,
      'pendingNotificationsCount': pending.length,
      'firebaseInitialized': _messaging != null,
    };
  }

  /// Dispose the service
  void dispose() {
    _notificationController.close();
    _tokenRefreshController.close();
  }
}
