import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/dashboard/data/models/dashboard_project_option_model.dart';
import 'package:prm_smart_task/features/dashboard/data/models/project_dashboard_model.dart';
import 'package:prm_smart_task/features/dashboard/data/models/user_dashboard_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserDashboardModel> getMyDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardMe);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid dashboard response format');
      }

      return UserDashboardModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ProjectDashboardModel> getProjectDashboard({
    required String projectId,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.dashboardProject(projectId));
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid project dashboard response format');
      }

      return ProjectDashboardModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<DashboardProjectOptionModel>> getProjectOptions() async {
    try {
      final workspaceResponse = await _dio.get(ApiConstants.myWorkspaces);
      final workspaceData = workspaceResponse.data;
      if (workspaceData is! List) {
        return const [];
      }

      final options = <DashboardProjectOptionModel>[];

      for (final item in workspaceData.whereType<Map<String, dynamic>>()) {
        final workspaceId = item['id']?.toString() ?? '';
        final workspaceName = item['name']?.toString() ?? 'Workspace';
        if (workspaceId.isEmpty) {
          continue;
        }

        final projectResponse = await _dio.get(
          ApiConstants.workspaceProjects(workspaceId),
        );
        final projectData = projectResponse.data;
        if (projectData is! List) {
          continue;
        }

        for (final project in projectData.whereType<Map<String, dynamic>>()) {
          final projectId = project['id']?.toString() ?? '';
          final projectName = project['name']?.toString() ?? '';
          if (projectId.isEmpty || projectName.isEmpty) {
            continue;
          }

          options.add(
            DashboardProjectOptionModel(
              projectId: projectId,
              projectName: projectName,
              workspaceId: workspaceId,
              workspaceName: workspaceName,
            ),
          );
        }
      }

      return options;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? 'Request failed';
  }
}
