import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/notification/application/states/notification_state.dart';
import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';
import 'package:prm_smart_task/features/notification/domain/repositories/notification_repository.dart';

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController(this._repository) : super(NotificationState.initial());

  final NotificationRepository _repository;

  Future<void> loadNotifications({bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final notificationsFuture = _repository.getNotifications();
      final unreadCountFuture = _repository.getUnreadCount();

      final notifications = await notificationsFuture;
      final unreadCount = await unreadCountFuture;

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final unreadCount = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: unreadCount);
    } catch (_) {}
  }

  Future<bool> markAsRead({required String notificationId}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);
    try {
      final updated = await _repository.markAsRead(notificationId: notificationId);

      final notifications = state.notifications
          .map((item) => item.id == notificationId ? updated : item)
          .toList();

      final unreadCount = notifications.where((item) => !item.isRead).length;

      state = state.copyWith(
        isSubmitting: false,
        notifications: notifications,
        unreadCount: unreadCount,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);
    try {
      await _repository.markAllAsRead();

      final notifications = state.notifications
          .map(
            (item) => item.isRead
                ? item
                : TaskNotification(
                    id: item.id,
                    type: item.type,
                    content: item.content,
                    isRead: true,
                    createdAt: item.createdAt,
                  ),
          )
          .toList();

      state = state.copyWith(
        isSubmitting: false,
        notifications: notifications,
        unreadCount: 0,
        infoMessage: 'Đã đánh dấu tất cả là đã đọc',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}
