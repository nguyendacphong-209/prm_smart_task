class TaskComment {
  const TaskComment({
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

  String get displayName => userFullName.trim().isNotEmpty ? userFullName : userEmail;
}
