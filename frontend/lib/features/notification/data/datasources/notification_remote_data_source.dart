import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/notification/data/models/task_notification_model.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TaskNotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications);
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskNotificationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.notificationUnreadCount);
      final data = response.data;
      if (data is! Map<String, dynamic>) return 0;
      return (data['unreadCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<TaskNotificationModel> markAsRead({required String notificationId}) async {
    try {
      final response = await _dio.put(
        ApiConstants.notificationMarkRead(notificationId),
      );

      return TaskNotificationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put(ApiConstants.notificationMarkAllRead);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? 'Request failed';
  }
}
