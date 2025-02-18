import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/firebase/firebase_options.dart';

class FirebaseService {
  static final userMetadataRepository = UserMetadataRepositoryRemote();

  static Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseMessaging.instance.requestPermission(provisional: true);

      // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          throw Exception('firebase_service: apnsToken is null');
        }
      }

      _syncFCMToken();
    }
    debugPrint('firebase_service: init success');
  }

  static Future<void> _syncFCMToken() async {
    await _waitUntilUserIsAuthenticated();
    final token = await userMetadataRepository.getFCMToken();
    if (token == null) {
      final newToken = await FirebaseMessaging.instance.getToken();
      if (newToken == null) {
        throw Exception('firebase_service: token is null');
      }
      await userMetadataRepository.setFCMToken(newToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      userMetadataRepository.setFCMToken(newToken);
    });
  }

  static Future<void> _waitUntilUserIsAuthenticated() async {
    while (await AuthService.getUser() == null) {
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
