import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/utils/app_constants.dart';

abstract class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseProjectUrl,
        publishableKey: AppConstants.supabaseProjectPublishableKey,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Supabase initialization warning/error: $e\n$stackTrace');
      }
    }
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
