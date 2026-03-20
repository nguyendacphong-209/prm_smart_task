import 'package:prm_smart_task/features/dashboard/domain/entities/dashboard_project_option.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/user_dashboard.dart';

abstract class DashboardRepository {
  Future<UserDashboard> getMyDashboard();

  Future<ProjectDashboard> getProjectDashboard({required String projectId});

  Future<List<DashboardProjectOption>> getProjectOptions();
}
