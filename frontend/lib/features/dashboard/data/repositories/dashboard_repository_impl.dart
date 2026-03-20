import 'package:prm_smart_task/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/dashboard_project_option.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/user_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<UserDashboard> getMyDashboard() async {
    final model = await _remote.getMyDashboard();
    return model.toEntity();
  }

  @override
  Future<ProjectDashboard> getProjectDashboard({required String projectId}) async {
    final model = await _remote.getProjectDashboard(projectId: projectId);
    return model.toEntity();
  }

  @override
  Future<List<DashboardProjectOption>> getProjectOptions() async {
    final models = await _remote.getProjectOptions();
    return models.map((item) => item.toEntity()).toList();
  }
}
