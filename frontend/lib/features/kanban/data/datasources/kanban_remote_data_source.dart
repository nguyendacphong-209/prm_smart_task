import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/kanban/data/models/kanban_board_model.dart';
import 'package:prm_smart_task/features/kanban/data/models/kanban_status_column_model.dart';
import 'package:prm_smart_task/features/kanban/data/models/kanban_task_card_model.dart';

class KanbanRemoteDataSource {
  const KanbanRemoteDataSource(this._dio);

  final Dio _dio;

  Future<KanbanBoardModel> getBoard({required String projectId}) async {
    try {
      final response = await _dio.get(ApiConstants.projectKanban(projectId));
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Dữ liệu kanban không hợp lệ');
      }

      return KanbanBoardModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<KanbanStatusColumnModel> createStatus({
    required String projectId,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.projectStatuses(projectId),
        data: {'name': name},
      );

      return KanbanStatusColumnModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<KanbanTaskCardModel> moveTaskToStatus({
    required String taskId,
    required String statusId,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.taskMoveStatus(taskId),
        data: {'statusId': statusId},
      );

      return KanbanTaskCardModel.fromJson(response.data as Map<String, dynamic>);
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
