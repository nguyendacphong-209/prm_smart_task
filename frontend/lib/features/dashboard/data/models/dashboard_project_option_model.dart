import 'package:prm_smart_task/features/dashboard/domain/entities/dashboard_project_option.dart';

class DashboardProjectOptionModel {
  const DashboardProjectOptionModel({
    required this.projectId,
    required this.projectName,
    required this.workspaceId,
    required this.workspaceName,
  });

  final String projectId;
  final String projectName;
  final String workspaceId;
  final String workspaceName;

  DashboardProjectOption toEntity() {
    return DashboardProjectOption(
      projectId: projectId,
      projectName: projectName,
      workspaceId: workspaceId,
      workspaceName: workspaceName,
    );
  }
}
