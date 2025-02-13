import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:notiyou/services/firebase/firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    debugPrint('firebase_service: init');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('firebase_service: init success');
  }
}
