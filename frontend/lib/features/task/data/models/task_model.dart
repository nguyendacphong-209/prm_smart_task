import 'package:prm_smart_task/features/task/data/models/task_assignee_detail_model.dart';
import 'package:prm_smart_task/features/task/data/models/task_label_detail_model.dart';
import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.priority,
    this.statusId,
    this.description,
    this.deadline,
    this.createdAt,
    this.assignees = const [],
    this.labels = const [],
  });

  final String id;
  final String projectId;
  final String? statusId;
  final String title;
  final String? description;
  final String priority;
  final DateTime? deadline;
  final DateTime? createdAt;
  final List<TaskAssigneeDetailModel> assignees;
  final List<TaskLabelDetailModel> labels;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<TaskAssigneeDetailModel> parseAssignees(dynamic data) {
      if (data is! List) return const [];
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              return TaskAssigneeDetailModel.fromJson(item);
            }
            return null;
          })
          .whereType<TaskAssigneeDetailModel>()
          .toList();
    }

    List<TaskLabelDetailModel> parseLabels(dynamic data) {
      if (data is! List) return const [];
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              return TaskLabelDetailModel.fromJson(item);
            }
            return null;
          })
          .whereType<TaskLabelDetailModel>()
          .toList();
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      statusId: json['statusId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: (json['priority']?.toString() ?? 'medium').toLowerCase(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      assignees: parseAssignees(json['assignees']),
      labels: parseLabels(json['labels']),
    );
  }

  AppTask toEntity() {
    return AppTask(
      id: id,
      projectId: projectId,
      statusId: statusId,
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      createdAt: createdAt,
      assignees: assignees.map((a) => a.toEntity()).toList(),
      labels: labels.map((l) => l.toEntity()).toList(),
    );
  }
}
