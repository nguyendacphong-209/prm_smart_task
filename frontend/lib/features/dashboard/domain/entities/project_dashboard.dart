class ProjectDashboard {
  const ProjectDashboard({
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
}
