import 'package:field_time/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseService {
  static FirebaseAuth get client => FirebaseAuth.instance;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Firebase initialization warning/error: $e\n$stackTrace');
      }
    }
  }

  static User? get currentUser => client.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
