import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/features/notifications/data/models/notification_model.dart';
import 'package:field_time/features/notifications/data/repositories/notification_repository.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final List<NotificationModel> filteredNotifications;
  final int unreadCount;
  final String selectedFilter;

  const NotificationsLoaded({
    required this.notifications,
    required this.filteredNotifications,
    required this.unreadCount,
    this.selectedFilter = 'all',
  });

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    List<NotificationModel>? filteredNotifications,
    int? unreadCount,
    String? selectedFilter,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        filteredNotifications,
        unreadCount,
        selectedFilter,
      ];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> loadNotifications({bool isRefresh = false}) async {
    final currentState = state;
    if (!isRefresh && currentState is! NotificationsLoaded) {
      emit(NotificationsLoading());
    }

    try {
      final list = await _repository.getNotifications();
      final filter = currentState is NotificationsLoaded ? currentState.selectedFilter : 'all';
      final filtered = _applyFilter(list, filter);
      final unread = list.where((n) => !n.isRead).length;

      emit(NotificationsLoaded(
        notifications: list,
        filteredNotifications: filtered,
        unreadCount: unread,
        selectedFilter: filter,
      ));
    } catch (e) {
      emit(NotificationsError('فشل تحميل الإشعارات: ${e.toString()}'));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications(isRefresh: true);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications(isRefresh: true);
    } catch (_) {}
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? targetId,
  }) async {
    try {
      await _repository.addNotification(
        title: title,
        body: body,
        type: type,
        targetId: targetId,
      );
      await loadNotifications(isRefresh: true);
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      await loadNotifications(isRefresh: true);
    } catch (_) {}
  }

  void filterNotifications(String filterType) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final filtered = _applyFilter(currentState.notifications, filterType);
      emit(currentState.copyWith(
        selectedFilter: filterType,
        filteredNotifications: filtered,
      ));
    }
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> list, String filter) {
    if (filter == 'all') return list;
    return list.where((n) => n.type.name == filter).toList();
  }
}
