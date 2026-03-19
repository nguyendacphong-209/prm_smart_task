import 'package:prm_smart_task/features/task/domain/entities/task_label_detail.dart';

class TaskLabelDetailModel {
  const TaskLabelDetailModel({
    required this.id,
    required this.name,
    this.color,
    this.createdById,
    this.creatorFullName,
  });

  final String id;
  final String name;
  final String? color;
  final String? createdById;
  final String? creatorFullName;

  factory TaskLabelDetailModel.fromJson(Map<String, dynamic> json) {
    return TaskLabelDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString(),
      createdById: json['createdById']?.toString(),
      creatorFullName: json['creatorFullName']?.toString(),
    );
  }

  TaskLabelDetail toEntity() {
    return TaskLabelDetail(
      id: id,
      name: name,
      color: color,
      createdById: createdById,
      creatorFullName: creatorFullName,
    );
  }
}
