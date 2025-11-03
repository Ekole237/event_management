import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Skip messaging permissions on Linux as it's not fully supported
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.linux) {
      await _requestNotificationPermissions();
    }

    await _setupFirestoreSettings();
  }

  static Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else {
        debugPrint('User declined or has not granted notification permission');
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  static Future<void> _setupFirestoreSettings() async {
    try {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Error setting up Firestore settings: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static User? get currentUser => auth.currentUser;

  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
