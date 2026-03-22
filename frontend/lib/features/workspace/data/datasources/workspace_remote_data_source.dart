import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/workspace/data/models/workspace_models.dart';

class WorkspaceRemoteDataSource {
  const WorkspaceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<WorkspaceModel>> getMyWorkspaces() async {
    try {
      final response = await _dio.get(ApiConstants.myWorkspaces);
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(WorkspaceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceModel> createWorkspace({required String name}) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaces,
        data: {'name': name},
      );
      return WorkspaceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceModel> updateWorkspace({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.workspaceDetail(workspaceId),
        data: {'name': name},
      );
      return WorkspaceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deleteWorkspace({required String workspaceId}) async {
    try {
      await _dio.delete(ApiConstants.workspaceDetail(workspaceId));
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceModel> getWorkspaceDetail({required String workspaceId}) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceDetail(workspaceId));
      return WorkspaceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<WorkspaceMemberModel>> getWorkspaceMembers({
    required String workspaceId,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceMembers(workspaceId));
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(WorkspaceMemberModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<WorkspaceMemberModel>> getWorkspaceAssignees({
    required String workspaceId,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceAssignees(workspaceId));
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(WorkspaceMemberModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceMemberModel> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaceInviteMember(workspaceId),
        data: {
          'email': email,
          'role': role,
        },
      );
      return WorkspaceMemberModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceMemberModel> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.workspaceMemberRole(workspaceId, userId),
        data: {'role': role},
      );
      return WorkspaceMemberModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<WorkspaceMemberModel> approveMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaceMemberApproveInvitation(workspaceId, userId),
      );
      return WorkspaceMemberModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> rejectMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await _dio.post(
        ApiConstants.workspaceMemberRejectInvitation(workspaceId, userId),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await _dio.delete(ApiConstants.workspaceMember(workspaceId, userId));
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

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Kết nối tới server đang chậm. Vui lòng thử lại sau.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối tới server. Vui lòng kiểm tra mạng.';
    }

    return e.message ?? 'Request failed';
  }
}
