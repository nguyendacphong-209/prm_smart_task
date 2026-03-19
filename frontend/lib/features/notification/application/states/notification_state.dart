import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';

class NotificationState {
  const NotificationState({
    required this.notifications,
    required this.unreadCount,
    required this.isLoading,
    required this.isSubmitting,
    this.errorMessage,
    this.infoMessage,
  });

  final List<TaskNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  factory NotificationState.initial() {
    return const NotificationState(
      notifications: [],
      unreadCount: 0,
      isLoading: false,
      isSubmitting: false,
    );
  }

  NotificationState copyWith({
    List<TaskNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
