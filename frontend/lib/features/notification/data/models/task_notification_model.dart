import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';

DateTime? _parseDateTime(dynamic raw) {
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return null;

  final direct = DateTime.tryParse(value);
  if (direct != null) return direct;

  final normalized = value.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

class TaskNotificationModel {
  const TaskNotificationModel({
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

  factory TaskNotificationModel.fromJson(Map<String, dynamic> json) {
    return TaskNotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  TaskNotification toEntity() {
    return TaskNotification(
      id: id,
      type: type,
      content: content,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
