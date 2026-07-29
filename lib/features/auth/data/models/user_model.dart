import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role; // 'user' or 'owner'
  final String city;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.city,
    this.createdAt,
  });

  bool get isOwner => role == 'owner';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      city: json['city'] as String? ?? 'القاهرة',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  factory UserModel.fromSupabase(User user, [Map<String, dynamic>? profileData]) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      fullName: profileData?['full_name'] as String? ??
          metadata['full_name'] as String? ??
          'لاعب جديد',
      email: user.email ?? profileData?['email'] as String? ?? '',
      phone: profileData?['phone'] as String? ??
          user.phone ??
          metadata['phone'] as String? ??
          '',
      avatarUrl: profileData?['avatar_url'] as String? ??
          metadata['avatar_url'] as String?,
      role: profileData?['role'] as String? ??
          metadata['role'] as String? ??
          'user',
      city: profileData?['city'] as String? ??
          metadata['city'] as String? ??
          'القاهرة',
      createdAt: profileData?['created_at'] != null
          ? DateTime.tryParse(profileData!['created_at'] as String)
          : DateTime.tryParse(user.createdAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'city': city,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    String? city,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        avatarUrl,
        role,
        city,
        createdAt,
      ];
}
