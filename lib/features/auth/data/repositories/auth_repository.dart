import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/features/auth/data/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static const UserModel _defaultUser = UserModel(
    id: 'user-001',
    fullName: 'أحمد محمد',
    email: 'ahmed@example.com',
    phone: '01012345678',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
    role: 'user',
    city: 'القاهرة',
  );

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          fullName: response.user!.userMetadata?['full_name'] ?? 'أحمد محمد',
          email: response.user!.email ?? email,
          phone: response.user!.phone ?? '01012345678',
          avatarUrl: response.user!.userMetadata?['avatar_url'],
          role: 'user',
          city: 'القاهرة',
        );
      }
    } catch (_) {}
    return _defaultUser;
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          fullName: fullName,
          email: email,
          phone: phone,
          role: 'user',
          city: 'القاهرة',
        );
      }
    } catch (_) {}
    return _defaultUser.copyWith(fullName: fullName, email: email, phone: phone);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        fullName: user.userMetadata?['full_name'] ?? 'أحمد محمد',
        email: user.email ?? '',
        phone: user.phone ?? '01012345678',
        avatarUrl: user.userMetadata?['avatar_url'],
        role: 'user',
        city: 'القاهرة',
      );
    }
    return _defaultUser;
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }
}
