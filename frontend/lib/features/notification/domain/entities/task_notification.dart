class TaskNotification {
  const TaskNotification({
    required this.id,
    required this.type,
    required this.content,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String type;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  bool get isTaskAssigned => type.toUpperCase() == 'TASK_ASSIGNED';

  bool get isTaskStatusChanged => type.toUpperCase() == 'TASK_STATUS_CHANGED';
}
