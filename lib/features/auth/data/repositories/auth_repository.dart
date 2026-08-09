import 'package:field_time/core/utils/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/core/errors/failures.dart';
import 'package:field_time/features/auth/data/models/user_model.dart';

class AuthRepository {
  final SupabaseClient? _customSupabase;
  final FirebaseAuth? _customFirebaseAuth;

  AuthRepository({SupabaseClient? supabase, FirebaseAuth? firebaseAuth})
      : _customSupabase = supabase,
        _customFirebaseAuth = firebaseAuth;

  SupabaseClient get _supabase => _customSupabase ?? Supabase.instance.client;
  FirebaseAuth get _firebaseAuth => _customFirebaseAuth ?? FirebaseAuth.instance;


  /// Sign in with email and password using Supabase Auth and fetch profile
  Future<UserModel> loginWithEmailAndPassword({
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
      final token = response.session?.accessToken ?? user.id;
      await SecureStorage.saveToken(token); // Save the token for session management
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

  Future<bool> loginWithGoogle() async {
    try {
      final gUser = await GoogleSignIn().signIn();
      final gAuth = await gUser?.authentication;
      if (gAuth?.idToken != null) {
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: gAuth!.idToken!,
          accessToken: gAuth.accessToken,
        );
        if (response.user != null) {
          final token = response.session?.accessToken ?? response.user!.id;
          await SecureStorage.saveToken(token);
          // Sync profile in public.users
          await _supabase.from('users').upsert({
            'id': response.user!.id,
            'full_name': response.user!.userMetadata?['full_name'] ?? gUser?.displayName ?? 'مستخدم جوجل',
            'email': response.user!.email ?? gUser?.email ?? '',
            'avatar_url': response.user!.userMetadata?['avatar_url'] ?? gUser?.photoUrl,
            'role': 'user',
            'city': 'القاهرة',
          });
          return true;
        }
      }

      // Fallback Firebase Auth if Supabase Google Auth is not configured
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth?.accessToken,
        idToken: gAuth?.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final fbUser = userCredential.user;
      if (fbUser != null) {
        final token = await fbUser.getIdToken() ?? fbUser.uid;
        await SecureStorage.saveToken(token);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Register a new user in Supabase Auth & insert user record in PostgreSQL 'users' table
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

      final token = response.session?.accessToken ?? user.id;
      await SecureStorage.saveToken(token);

      // Upsert profile into PostgreSQL 'users' table
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
        await _supabase.from('users').upsert(profileMap);
      } catch (e) {
        if (kDebugMode) print('User profile upsert warning: $e');
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

  Future<void> sendOtpForNewUser(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: true);
    } catch (e) {
      throw 'Error from send OTP for new user $e';
    }
  }

  Future<void> sendOtpForExistingUser(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
    } catch (e) {
      throw 'Error from send OTP for existing user $e';
    }
  }

  Future<bool> validateOtp({required String email, required String otp}) async {
    try {
      final result = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      if (result.session != null) {
        await SecureStorage.saveToken(result.session!.accessToken);
      }
      return result.session != null;
    } catch (e) {
      throw 'Error from verify OTP $e';
    }
  }

  /// Request password reset via Supabase Auth (sends reset email/OTP)
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } catch (e) {
      throw const AuthFailure('فشل إرسال رابط إعادة تعيين كلمة المرور');
    }
  }

  /// Update password for the user session (Confirm Reset Password)
  Future<void> confirmPasswordReset({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthExceptionMessage(e.message));
    } catch (e) {
      throw const AuthFailure('فشل إعادة تعيين كلمة المرور');
    }
  }

  /// Get current session user from Supabase Auth & users table
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

  /// Helper to fetch user profile row from Supabase PostgreSQL 'users' table
  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
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
        await _supabase.from('users').upsert({
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
        await _supabase.from('users').upsert({
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

  /// Alias for loginWithEmailAndPassword
  Future<UserModel> login({
    required String email,
    required String password,
  }) => loginWithEmailAndPassword(email: email, password: password);

  /// Sign out current Supabase auth session and clear stored tokens
  Future<void> logout() async {
    try {
      await SecureStorage.deleteToken();
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
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already_exists')) {
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
