import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/firebase/firebase_options.dart';
import 'package:notiyou/services/local_notification_service.dart';
import 'package:notiyou/services/notification/notification_event.dart';
import 'package:notiyou/services/notification/notification_handler.dart';
import 'package:notiyou/services/notification/notification_handler_interface.dart';

class FirebaseService {
  static final userMetadataRepository = UserMetadataRepositoryRemote();
  static final NotificationHandler _notificationHandler =
      NotificationHandlerImpl();

  static Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final settings = await FirebaseMessaging.instance
            .requestPermission(provisional: true);
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          // TODO: 원격 노티 권한을 거절한 경우에 대한 시나리오 추가
          throw Exception('firebase_service: authorizationStatus is denied');
        }

        // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
        if (Platform.isIOS) {
          String? apnsToken;
          const maxAttempts = 20;
          for (var i = 0; i < maxAttempts; i++) {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) {
              break;
            }
            await Future.delayed(const Duration(seconds: 1));
          }
          if (apnsToken == null) {
            throw Exception('firebase_service: Problem with getting apnsToken');
          }
        }

        // 앱 종료 상태에서 푸시 알림 처리
        final initialMessage =
            await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          _validateNotification(initialMessage);

          final event = NotificationEvent.getNotificationEvent(
              initialMessage.data['notification_type']);

          _notificationHandler.handleNotification(event, initialMessage.data);
        }

        // 앱 백그라운드 실행 상태에서 푸시 알림 처리
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _validateNotification(message);

          final event = NotificationEvent.getNotificationEvent(
              message.data['notification_type']);

          _notificationHandler.handleNotification(event, message.data);
        });

        // 앱 포그라운드 실행 상태에서 푸시 알림 처리
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _validateNotification(message);

          LocalNotificationService.showNotification(
            id: message.messageId.hashCode,
            title: message.notification?.title,
            body: message.notification?.body,
            notificationType: message.data['notification_type'],
          );
        });

        _syncFCMToken();
      }
      debugPrint('firebase_service: 초기화 완료');
    } catch (e) {
      throw Exception('firebase_service: 초기화 실패: $e');
    }
  }

  static Future<void> _syncFCMToken() async {
    try {
      await _waitUntilUserIsAuthenticated();
      final remoteStoredToken = await userMetadataRepository.getFCMToken();
      final deviceStoredToken = await FirebaseMessaging.instance.getToken();
      if (deviceStoredToken == null) {
        throw Exception('firebase_service: token is null');
      }

      final isTokenChanged = remoteStoredToken != deviceStoredToken;
      if (isTokenChanged) {
        await userMetadataRepository.setFCMToken(deviceStoredToken);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        userMetadataRepository.setFCMToken(newToken);
      });
    } catch (e) {
      throw Exception('firebase_service: syncFCMToken failed: $e');
    }
  }

  static Future<void> _waitUntilUserIsAuthenticated() async {
    const maxAttempts = 50;
    for (var i = 0; i < maxAttempts; i++) {
      if (await AuthService.getUser() != null) {
        return;
      }
      await Future.delayed(const Duration(seconds: 10));
    }
    throw Exception('firebase_service: 사용자 인증 대기 시간이 초과되었습니다.');
  }

  static void _validateNotification(RemoteMessage message) {
    if (message.notification == null) {
      throw Exception('firebase_service: message.notification is null');
    }
  }
}
