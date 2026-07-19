import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/storage_service.dart';
import '../services/mobile_api_service.dart';

/// Inisialisasi & kelola FCM token untuk push notifications.
///
/// Flow:
/// 1. Request permission (Android: granted by default).
/// 2. Get FCM token dari FirebaseMessaging.
/// 3. POST ke /api/mobile/device-token untuk register di server.
/// 4. Listen onTokenRefresh → re-register jika token rotated.
/// 5. Listen onMessage (foreground) → tampilkan local notification.
/// 6. Pada logout: DELETE /api/mobile/device-token.
class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService instance = PushNotificationService._internal();

  final _firebase = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();

  /// Init — panggil sekali setelah user login berhasil.
  Future<void> init() async {
    // 1. Permission
    final settings = await _firebase.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('[FCM] permission: ${settings.authorizationStatus}');
    }

    // 2. Local notification channel (Android)
    const androidChannel = AndroidNotificationChannel(
      'absensi_guru_notifications',
      'Notifikasi Absensi Guru',
      description: 'Notifikasi slip gaji, absensi, dst.',
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotif.initialize(initSettings);

    // 3. Get FCM token
    final fcmToken = await _firebase.getToken();
    if (fcmToken != null) {
      await _registerIfNeeded(fcmToken);
    }

    // 4. Listen token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerIfNeeded);

    // 5. Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _registerIfNeeded(String token) async {
    final stored = await StorageService.instance.getFcmToken();
    final alreadyRegistered = await StorageService.instance.isFcmRegistered();

    // Token berubah atau belum pernah didaftarkan → register ulang
    if (stored != token || !alreadyRegistered) {
      try {
        await MobileApiService.instance.registerDeviceToken(token: token);
        await StorageService.instance.setFcmToken(token);
        await StorageService.instance.setFcmRegistered(true);
        if (kDebugMode) debugPrint('[FCM] token registered: ${token.substring(0, 16)}...');
      } catch (e) {
        if (kDebugMode) debugPrint('[FCM] register failed: $e');
        // Akan retry on next app launch (isFcmRegistered masih false).
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) debugPrint('[FCM] foreground: ${message.notification?.title}');

    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notif.title ?? 'Notifikasi',
      notif.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'absensi_guru_notifications',
          'Notifikasi Absensi Guru',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Unregister device token — panggil saat user logout.
  Future<void> unregister() async {
    final token = await StorageService.instance.getFcmToken();
    if (token != null) {
      await MobileApiService.instance.unregisterDeviceToken(token);
    }
    await StorageService.instance.setFcmRegistered(false);
  }
}
