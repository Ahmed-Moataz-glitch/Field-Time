import 'package:equatable/equatable.dart';

enum NotificationType { booking, reminder, offer, general }

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String createdAt;
  final String? targetId;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.targetId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String? t) {
      switch (t?.toLowerCase()) {
        case 'booking':
          return NotificationType.booking;
        case 'reminder':
          return NotificationType.reminder;
        case 'offer':
          return NotificationType.offer;
        default:
          return NotificationType.general;
      }
    }

    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: parseType(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? 'الآن',
      targetId: json['target_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt,
      'target_id': targetId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    String? createdAt,
    String? targetId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        isRead,
        createdAt,
        targetId,
      ];
}
