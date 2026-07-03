import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/point.dart';
import 'debug_log.dart';

class DiscoveryNotificationPayload {
  const DiscoveryNotificationPayload({
    required this.poiId,
    required this.language,
    required this.delaySeconds,
  });

  final String poiId;
  final String language;
  final int delaySeconds;

  String toPayloadString() {
    return jsonEncode(<String, dynamic>{
      'type': 'discovery_proximity',
      'poiId': poiId,
      'language': language,
      'delaySeconds': delaySeconds,
    });
  }

  static DiscoveryNotificationPayload? tryParse(String? rawPayload) {
    if (rawPayload == null || rawPayload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final poiId = decoded['poiId'] as String?;
      final language = decoded['language'] as String?;
      final delaySeconds = decoded['delaySeconds'] as int?;
      if (decoded['type'] != 'discovery_proximity' ||
          poiId == null ||
          poiId.isEmpty ||
          language == null ||
          language.isEmpty) {
        return null;
      }

      return DiscoveryNotificationPayload(
        poiId: poiId,
        language: language,
        delaySeconds: delaySeconds ?? 0,
      );
    } catch (error) {
      DebugLog().log(
        '[NotificationService] failed to parse payload error=$error payload=$rawPayload',
      );
      return null;
    }
  }
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  static const String discoveryChannelId = 'discovery_trigger';
  static const String discoveryChannelName = 'Découvertes à proximité';
  static const String discoveryChannelDescription =
      'Alerte avant lecture automatique des points détectés à proximité.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<DiscoveryNotificationPayload> _tapController =
      StreamController<DiscoveryNotificationPayload>.broadcast();
  final Set<int> _activeNotificationIds = <int>{};

  Future<void>? _initFuture;
  bool _permissionsEnsured = false;
  DiscoveryNotificationPayload? _pendingPayload;

  Stream<DiscoveryNotificationPayload> get tapStream => _tapController.stream;
  DiscoveryNotificationPayload? get pendingPayload => _pendingPayload;

  Future<void> init() {
    return _initFuture ??= _initInternal();
  }

  Future<void> ensurePermissions() async {
    try {
      await init();
      if (_permissionsEnsured) {
        return;
      }

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final macosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();

      final androidGranted = await androidPlugin
          ?.requestNotificationsPermission();
      final iosGranted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: false,
        sound: false,
      );
      final macosGranted = await macosPlugin?.requestPermissions(
        alert: true,
        badge: false,
        sound: false,
      );

      _permissionsEnsured = true;
      DebugLog().log(
        '[NotificationService] permissions ensured '
        'android=$androidGranted ios=$iosGranted macos=$macosGranted',
      );
    } catch (error) {
      DebugLog().log(
        '[NotificationService] permission request failed error=$error',
      );
    }
  }

  Future<void> showProximityNotification({
    required Point poi,
    required String language,
    required int delaySeconds,
    bool vibrationEnabled = true,
  }) async {
    try {
      await init();
      await ensurePermissions();

      final notificationId = notificationIdForPoi(poi);
      final title = _buildTitle(language);
      final body = _buildBody(
        language: language,
        poiName: poi.localizedName(language).trim(),
        delaySeconds: delaySeconds,
      );

      await cancelDiscoveryNotification(notificationId);
      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            discoveryChannelId,
            discoveryChannelName,
            channelDescription: discoveryChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: false,
            enableVibration: vibrationEnabled,
            vibrationPattern: vibrationEnabled
                ? Int64List.fromList(<int>[0, 120, 80, 120])
                : null,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.reminder,
            ticker: title,
            icon: 'ic_launcher',
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentBanner: true,
            presentList: true,
            presentSound: false,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        payload: DiscoveryNotificationPayload(
          poiId: poi.id,
          language: language,
          delaySeconds: delaySeconds,
        ).toPayloadString(),
      );

      _activeNotificationIds.add(notificationId);
      DebugLog().log(
        '[NotificationService] proximity notification shown '
        'poi=${poi.id} lang=$language delay=${delaySeconds}s vibration=$vibrationEnabled',
      );
    } catch (error) {
      DebugLog().log(
        '[NotificationService] show proximity notification failed '
        'poi=${poi.id} error=$error',
      );
    }
  }

  Future<void> cancelDiscoveryNotification([int? notificationId]) async {
    try {
      await init();

      if (notificationId != null) {
        await _plugin.cancel(id: notificationId);
        _activeNotificationIds.remove(notificationId);
        DebugLog().log(
          '[NotificationService] notification cancelled id=$notificationId',
        );
        return;
      }

      final ids = _activeNotificationIds.toList(growable: false);
      for (final id in ids) {
        await _plugin.cancel(id: id);
      }
      _activeNotificationIds.clear();
      DebugLog().log(
        '[NotificationService] all discovery notifications cancelled',
      );
    } catch (error) {
      DebugLog().log(
        '[NotificationService] cancel notification failed id=$notificationId error=$error',
      );
    }
  }

  int notificationIdForPoi(Point poi) {
    return poi.id.hashCode & 0x7fffffff;
  }

  void markPendingPayloadHandled(DiscoveryNotificationPayload payload) {
    if (_pendingPayload?.poiId != payload.poiId) {
      return;
    }

    _pendingPayload = null;
    DebugLog().log(
      '[NotificationService] pending payload handled poi=${payload.poiId}',
    );
  }

  Future<void> _initInternal() async {
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: false,
      defaultPresentSound: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        discoveryChannelId,
        discoveryChannelName,
        description: discoveryChannelDescription,
        importance: Importance.max,
        playSound: false,
        enableVibration: true,
      ),
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _storePayload(
        DiscoveryNotificationPayload.tryParse(
          launchDetails?.notificationResponse?.payload,
        ),
        source: 'launch',
      );
    }

    DebugLog().log(
      '[NotificationService] initialized '
      'channel=$discoveryChannelId dnd_detection=not_implemented',
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _storePayload(
      DiscoveryNotificationPayload.tryParse(response.payload),
      source: response.notificationResponseType.name,
    );
  }

  void _storePayload(
    DiscoveryNotificationPayload? payload, {
    required String source,
  }) {
    if (payload == null) {
      return;
    }

    _pendingPayload = payload;
    _tapController.add(payload);
    DebugLog().log(
      '[NotificationService] notification tapped '
      'poi=${payload.poiId} delay=${payload.delaySeconds}s source=$source',
    );
  }

  String _buildTitle(String language) {
    return language == 'en' ? 'You are nearby' : 'Tu es à proximité !';
  }

  String _buildBody({
    required String language,
    required String poiName,
    required int delaySeconds,
  }) {
    if (language == 'en') {
      if (delaySeconds <= 0) {
        return '$poiName is ready. Audio starts now.';
      }
      return '$poiName is nearby. Audio starts in $delaySeconds seconds.';
    }

    if (delaySeconds <= 0) {
      return '$poiName est prêt. L’audio démarre maintenant.';
    }
    return '$poiName est à proximité. L’audio démarre dans $delaySeconds secondes.';
  }
}
