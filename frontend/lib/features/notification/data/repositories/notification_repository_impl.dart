import 'package:prm_smart_task/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';
import 'package:prm_smart_task/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<TaskNotification>> getNotifications() async {
    final items = await _remote.getNotifications();
    return items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<int> getUnreadCount() {
    return _remote.getUnreadCount();
  }

  @override
  Future<TaskNotification> markAsRead({required String notificationId}) async {
    final item = await _remote.markAsRead(notificationId: notificationId);
    return item.toEntity();
  }

  @override
  Future<void> markAllAsRead() {
    return _remote.markAllAsRead();
  }
}
