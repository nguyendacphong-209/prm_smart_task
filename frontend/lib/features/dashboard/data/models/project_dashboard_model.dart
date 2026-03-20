import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';

Map<String, int> _parseCountMap(dynamic raw) {
  if (raw is! Map) {
    return const {};
  }

  final parsed = <String, int>{};
  raw.forEach((key, value) {
    final normalizedKey = key?.toString() ?? '';
    if (normalizedKey.isEmpty) {
      return;
    }

    parsed[normalizedKey] = (value as num?)?.toInt() ?? 0;
  });

  return parsed;
}

class ProjectDashboardModel {
  const ProjectDashboardModel({
    required this.projectId,
    required this.projectName,
    required this.completionPercentage,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasksByStatus,
    required this.tasksByPriority,
  });

  final String projectId;
  final String projectName;
  final double completionPercentage;
  final int totalTasks;
  final int completedTasks;
  final Map<String, int> tasksByStatus;
  final Map<String, int> tasksByPriority;

  factory ProjectDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProjectDashboardModel(
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      tasksByStatus: _parseCountMap(json['tasksByStatus']),
      tasksByPriority: _parseCountMap(json['tasksByPriority']),
    );
  }

  ProjectDashboard toEntity() {
    return ProjectDashboard(
      projectId: projectId,
      projectName: projectName,
      completionPercentage: completionPercentage,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      tasksByStatus: tasksByStatus,
      tasksByPriority: tasksByPriority,
    );
  }
}
