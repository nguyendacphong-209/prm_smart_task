import 'package:prm_smart_task/features/collaboration/domain/entities/task_comment.dart';

DateTime? _parseDateTime(dynamic raw) {
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return null;

  final direct = DateTime.tryParse(value);
  if (direct != null) return direct;

  final normalized = value.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

class TaskCommentModel {
  const TaskCommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.content,
    required this.mentionedEmails,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String userId;
  final String userEmail;
  final String userFullName;
  final String content;
  final List<String> mentionedEmails;
  final DateTime? createdAt;

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    final mentionedEmails = (json['mentionedEmails'] as List?)
            ?.map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];

    return TaskCommentModel(
      id: json['id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mentionedEmails: mentionedEmails,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  TaskComment toEntity() {
    return TaskComment(
      id: id,
      taskId: taskId,
      userId: userId,
      userEmail: userEmail,
      userFullName: userFullName,
      content: content,
      mentionedEmails: mentionedEmails,
      createdAt: createdAt,
    );
  }
}
