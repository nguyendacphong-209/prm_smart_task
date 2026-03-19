import 'package:prm_smart_task/features/task/domain/entities/task_assignee_detail.dart';

class TaskAssigneeDetailModel {
  const TaskAssigneeDetailModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String fullName;
  final String? avatarUrl;

  factory TaskAssigneeDetailModel.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeDetailModel(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  TaskAssigneeDetail toEntity() {
    return TaskAssigneeDetail(
      userId: userId,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}
