import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';

abstract class NotificationRepository {
  Future<List<TaskNotification>> getNotifications();

  Future<int> getUnreadCount();

  Future<TaskNotification> markAsRead({required String notificationId});

  Future<void> markAllAsRead();
}
