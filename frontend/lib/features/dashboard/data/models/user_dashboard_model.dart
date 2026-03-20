import 'package:prm_smart_task/features/dashboard/domain/entities/user_dashboard.dart';

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

class UserDashboardModel {
  const UserDashboardModel({
    required this.totalAssignedTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.dueSoonTasks,
    required this.tasksByPriority,
    required this.tasksByStatus,
  });

  final int totalAssignedTasks;
  final int completedTasks;
  final int overdueTasks;
  final int dueSoonTasks;
  final Map<String, int> tasksByPriority;
  final Map<String, int> tasksByStatus;

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) {
    return UserDashboardModel(
      totalAssignedTasks: (json['totalAssignedTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdueTasks'] as num?)?.toInt() ?? 0,
      dueSoonTasks: (json['dueSoonTasks'] as num?)?.toInt() ?? 0,
      tasksByPriority: _parseCountMap(json['tasksByPriority']),
      tasksByStatus: _parseCountMap(json['tasksByStatus']),
    );
  }

  UserDashboard toEntity() {
    return UserDashboard(
      totalAssignedTasks: totalAssignedTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      dueSoonTasks: dueSoonTasks,
      tasksByPriority: tasksByPriority,
      tasksByStatus: tasksByStatus,
    );
  }
}
