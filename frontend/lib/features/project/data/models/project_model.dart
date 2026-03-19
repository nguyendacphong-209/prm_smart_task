import 'package:prm_smart_task/features/project/domain/entities/project.dart';

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final DateTime? createdAt;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspaceId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      workspaceId: workspaceId,
      name: name,
      description: description,
      createdAt: createdAt,
    );
  }
}
