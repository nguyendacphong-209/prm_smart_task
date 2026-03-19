import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';

class TaskStatusOptionModel {
  const TaskStatusOptionModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory TaskStatusOptionModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusOptionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  TaskStatusOption toEntity() {
    return TaskStatusOption(
      id: id,
      name: name,
    );
  }
}
