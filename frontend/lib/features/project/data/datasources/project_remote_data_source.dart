import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/project/data/models/project_model.dart';

class ProjectRemoteDataSource {
  const ProjectRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ProjectModel>> getProjectsByWorkspace({required String workspaceId}) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceProjects(workspaceId));
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(ProjectModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ProjectModel> createProject({
    required String workspaceId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaceProjects(workspaceId),
        data: {
          'name': name,
          'description': description,
        },
      );

      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ProjectModel> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.projectDetail(projectId),
        data: {
          'name': name,
          'description': description,
        },
      );

      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deleteProject({required String projectId}) async {
    try {
      await _dio.delete(ApiConstants.projectDetail(projectId));
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
