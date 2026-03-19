class TaskAssigneeDetail {
  const TaskAssigneeDetail({
    required this.userId,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String fullName;
  final String? avatarUrl;

  String get displayName => fullName.isNotEmpty ? fullName : email;
}
