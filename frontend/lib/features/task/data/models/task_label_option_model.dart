import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';

class TaskLabelOptionModel {
  const TaskLabelOptionModel({
    required this.id,
    required this.name,
    this.color,
  });

  final String id;
  final String name;
  final String? color;

  factory TaskLabelOptionModel.fromJson(Map<String, dynamic> json) {
    return TaskLabelOptionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString(),
    );
  }

  TaskLabelOption toEntity() {
    return TaskLabelOption(
      id: id,
      name: name,
      color: color,
    );
  }
}
