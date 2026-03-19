import 'package:prm_smart_task/features/task/domain/entities/task_assignee_detail.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_detail.dart';

class AppTask {
  const AppTask({
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
  final List<TaskAssigneeDetail> assignees;
  final List<TaskLabelDetail> labels;

  // Legacy properties for backward compatibility
  List<String> get assigneeIds => assignees.map((a) => a.userId).toList();
  List<String> get labelIds => labels.map((l) => l.id).toList();
}
