import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/notification/domain/entities/notification_entity.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../storage/preferences_service.dart';

@lazySingleton
class LocalNotificationService {
  LocalNotificationService(this._repository, this._prefs);

  final NotificationRepository _repository;
  final PreferencesService _prefs;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _pollInterval = Duration(minutes: 1);

  static const _maxPerPoll = 5;
  static const _maxStoredIds = 300;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'vaults_updates',
      'Vaults updates',
      channelDescription: 'Orders, offers and account updates',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  bool _initialized = false;
  bool _signedIn = false;
  bool _polling = false;
  Timer? _timer;

  bool get isEnabled => _prefs.isPushNotificationsEnabled();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await _ensureInitialized();
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> onSignedIn() async {
    _signedIn = true;
    await _start();
  }

  Future<void> onSignedOut() async {
    _signedIn = false;
    _stop();
    await _prefs.clearNotifiedNotificationIds();
    if (_initialized) await _plugin.cancelAll();
  }

  Future<bool> setEnabled(bool enabled) async {
    if (!enabled) {
      await _prefs.setPushNotificationsEnabled(false);
      _stop();
      if (_initialized) await _plugin.cancelAll();
      return false;
    }

    if (!await requestPermission()) {
      await _prefs.setPushNotificationsEnabled(false);
      return false;
    }

    await _prefs.setPushNotificationsEnabled(true);
    await _prefs.clearNotifiedNotificationIds();
    await _start();
    return true;
  }

  Future<void> _start() async {
    if (!_signedIn || !isEnabled || _timer != null) return;
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
    await requestPermission();
    await _poll();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    if (_polling || !_signedIn || !isEnabled) return;
    _polling = true;
    try {
      final notifications = await _repository.fetchMyNotifications();
      if (!_signedIn || !isEnabled) return;

      final stored = _prefs.getNotifiedNotificationIds();
      final notified = <String>{...?stored};

      if (stored != null) {
        final fresh =
            notifications
                .where((n) => !n.isRead && !notified.contains(n.uuid))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        for (final n in fresh.take(_maxPerPoll)) {
          await _show(n);
        }
      }

      notified.addAll(notifications.map((n) => n.uuid));
      final ids = notified.toList();
      await _prefs.setNotifiedNotificationIds(
        ids.length > _maxStoredIds
            ? ids.sublist(ids.length - _maxStoredIds)
            : ids,
      );
    } catch (e) {
      debugPrint('LocalNotificationService poll failed: $e');
    } finally {
      _polling = false;
    }
  }

  Future<void> _show(NotificationEntity n) async {
    await _ensureInitialized();
    await _plugin.show(
      id: n.uuid.hashCode & 0x7fffffff,
      title: n.title,
      body: n.message,
      notificationDetails: _details,
      payload: n.uuid,
    );
  }
}
