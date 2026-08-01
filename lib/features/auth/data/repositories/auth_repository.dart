import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/auth/data/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  /// Sign in with email and password using Supabase Auth and fetch profile
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('لم يتم العثور على بيانات المستخدم');
      }

      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabase(user, profile);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } on Failure {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Login Error: $e');
      throw const AuthFailure('حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.');
    }
  }

  /// Register a new user in Supabase Auth & insert profile record in PostgreSQL
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'user',
    String city = 'القاهرة',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'city': city,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('فشلت عملية إنشاء الحساب');
      }

      // Upsert profile into PostgreSQL 'profiles' table
      final profileMap = {
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'city': city,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await _supabase.from('profiles').upsert(profileMap);
      } catch (e) {
        if (kDebugMode) print('Profile upsert warning: $e');
      }

      return UserModel.fromSupabase(user, profileMap);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } on Failure {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Register Error: $e');
      throw const AuthFailure('حدث خطأ أثناء إنشاء الحساب.');
    }
  }

  /// Request password reset via Supabase Auth
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } catch (e) {
      throw const AuthFailure('فشل إرسال رابط إعادة تعيين كلمة المرور');
    }
  }

  /// Get current session user from Supabase Auth & profiles table
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabase(user, profile);
    } catch (e) {
      if (kDebugMode) print('GetCurrentUser Error: $e');
      return null;
    }
  }

  /// Helper to fetch user profile row from Supabase PostgreSQL database
  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      if (kDebugMode) print('FetchProfile Error: $e');
      return null;
    }
  }

  static UserModel? _mockUser;

  /// Update user profile details (fullName, phone, city)
  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
    required String city,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.auth.updateUser(UserAttributes(
          data: {'full_name': fullName, 'phone': phone, 'city': city},
        ));
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'phone': phone,
          'city': city,
        });
      }
    } catch (_) {}

    final current = await getCurrentUser() ??
        _mockUser ??
        const UserModel(
          id: 'u1',
          fullName: 'أحمد محمد',
          email: 'ahmed@fieldtime.app',
          phone: '01012345678',
          role: 'user',
          city: 'القاهرة',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
        );

    _mockUser = current.copyWith(
      fullName: fullName,
      phone: phone,
      city: city,
    );

    return _mockUser!;
  }

  /// Update user avatar URL
  Future<UserModel> updateAvatar(String avatarUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.auth.updateUser(UserAttributes(
          data: {'avatar_url': avatarUrl},
        ));
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'avatar_url': avatarUrl,
        });
      }
    } catch (_) {}

    final current = await getCurrentUser() ??
        _mockUser ??
        const UserModel(
          id: 'u1',
          fullName: 'أحمد محمد',
          email: 'ahmed@fieldtime.app',
          phone: '01012345678',
          role: 'user',
          city: 'القاهرة',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
        );

    _mockUser = current.copyWith(avatarUrl: avatarUrl);
    return _mockUser!;
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      }
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } catch (e) {
      throw const AuthFailure('فشل تغيير كلمة المرور');
    }
  }

  /// Sign out current Supabase auth session
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('حدث خطأ أثناء تسجيل الخروج');
    }
  }

  /// Translate Supabase English error messages to user-friendly Arabic messages
  String _mapAuthExceptionMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (lower.contains('user already registered') || lower.contains('already_exists')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }
    if (lower.contains('password should be at least')) {
      return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
    }
    if (lower.contains('rate limit')) {
      return 'لقد تجاوزت عدد المحاولات المسموح بها. حاول لاحقاً.';
    }
    return message;
  }
}
