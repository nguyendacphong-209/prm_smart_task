class DashboardProjectOption {
  const DashboardProjectOption({
    required this.projectId,
    required this.projectName,
    required this.workspaceId,
    required this.workspaceName,
  });

  final String projectId;
  final String projectName;
  final String workspaceId;
  final String workspaceName;

  String get displayLabel => '$projectName • $workspaceName';
}
