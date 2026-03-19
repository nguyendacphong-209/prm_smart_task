import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/features/collaboration/data/models/task_attachment_model.dart';
import 'package:prm_smart_task/features/collaboration/data/models/task_comment_model.dart';

class CollaborationRemoteDataSource {
  const CollaborationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TaskCommentModel>> getComments({required String taskId}) async {
    try {
      final response = await _dio.get(ApiConstants.taskComments(taskId));
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskCommentModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<TaskCommentModel> addComment({
    required String taskId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.taskComments(taskId),
        data: {'content': content},
      );

      return TaskCommentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<TaskAttachmentModel>> getAttachments({required String taskId}) async {
    try {
      final response = await _dio.get(ApiConstants.taskAttachments(taskId));
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskAttachmentModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<TaskAttachmentModel> uploadAttachment({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.taskAttachmentMockUpload(taskId),
        data: formData,
      );

      return TaskAttachmentModel.fromJson(response.data as Map<String, dynamic>);
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
