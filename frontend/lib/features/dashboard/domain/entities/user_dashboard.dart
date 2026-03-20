class UserDashboard {
  const UserDashboard({
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
}
