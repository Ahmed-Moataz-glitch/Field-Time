import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:field_time/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  static final List<NotificationModel> _mockNotifications = [
    const NotificationModel(
      id: 'notif-1',
      userId: 'u1',
      title: 'تم تأكيد حجزك بنجاح! ⚽',
      body: 'تم تأكيد حجز ملعب أرينا سبورت يوم الأحد الساعة 18:00. رمز الحجز: #FT-8921',
      type: NotificationType.booking,
      isRead: false,
      createdAt: 'منذ 15 دقيقة',
      targetId: 'field-1',
    ),
    const NotificationModel(
      id: 'notif-2',
      userId: 'u1',
      title: 'تذكير بموعد المباراة! ⏰',
      body: 'مباراتك القادمة في ملعب جول ميكرز ستيبدأ خلال ساعتين. جهّز حذائك الرياضي!',
      type: NotificationType.reminder,
      isRead: false,
      createdAt: 'منذ ساعتين',
      targetId: 'field-2',
    ),
    const NotificationModel(
      id: 'notif-3',
      userId: 'u1',
      title: 'عرض جديد: خصم 25% 🔥',
      body: 'استمتع بخصم 25% على جميع الحجوزات من الأحد حتى الأربعاء. لا تفوّت الفرصة!',
      type: NotificationType.offer,
      isRead: true,
      createdAt: 'منذ يومين',
      targetId: 'field-3',
    ),
    const NotificationModel(
      id: 'notif-4',
      userId: 'u1',
      title: 'تأكيد حجز سابق',
      body: 'تم إنهاء مباراتك في ملعب فيكتوري ستاديوم. شاركنا تقييمك وانطباعك عن الملعب.',
      type: NotificationType.booking,
      isRead: true,
      createdAt: 'منذ 3 أيام',
      targetId: 'field-3',
    ),
  ];

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        final response = await _supabase
            .from('notifications')
            .select()
            .eq('user_id', currentUser.id)
            .order('created_at', ascending: false);
        if ((response as List).isNotEmpty) {
          return response.map((item) => NotificationModel.fromJson(item)).toList();
        }
      }
    } catch (_) {}

    return List.from(_mockNotifications);
  }

  Future<NotificationModel> addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? targetId,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    final userId = currentUser?.id ?? 'user-id-placeholder';

    final newNotif = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: 'الآن',
      targetId: targetId,
    );

    try {
      if (currentUser != null) {
        await _supabase.from('notifications').insert({
          'user_id': userId,
          'title': title,
          'body': body,
          'type': type.name,
          'is_read': false,
          'target_id': targetId,
        });
      }
    } catch (_) {}

    _mockNotifications.insert(0, newNotif);
    return newNotif;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (_) {}

    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        await _supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', currentUser.id);
      }
    } catch (_) {}

    for (var i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (_) {}

    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }
}
