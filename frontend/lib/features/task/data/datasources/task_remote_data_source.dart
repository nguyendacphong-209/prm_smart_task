import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/core/storage/auth_storage.dart';
import 'package:prm_smart_task/features/task/data/models/task_label_option_model.dart';
import 'package:prm_smart_task/features/task/data/models/task_model.dart';
import 'package:prm_smart_task/features/task/data/models/task_status_option_model.dart';

class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._dio);

  final Dio _dio;

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  List<String> _normalizeUuidList(List<String>? values) {
    if (values == null) {
      return const [];
    }

    final unique = <String>{};
    for (final raw in values) {
      final normalized = raw.trim();
      if (normalized.isEmpty) {
        continue;
      }

      if (_uuidRegExp.hasMatch(normalized)) {
        unique.add(normalized);
      }
    }

    return unique.toList()..sort();
  }

  Future<Options?> _authOptions() async {
    final token = await AuthStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    final normalized = token.trim().replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');
    return Options(headers: {'Authorization': 'Bearer $normalized'});
  }

  Future<List<TaskModel>> getTasksByProject({required String projectId}) async {
    try {
      final response = await _dio.get(ApiConstants.projectTasks(projectId));
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<TaskStatusOptionModel>> getStatusOptions({required String projectId}) async {
    try {
      final response = await _dio.get(ApiConstants.projectKanban(projectId));
      final data = response.data;
      if (data is! Map<String, dynamic>) return const [];

      final columns = data['columns'];
      if (columns is! List) return const [];

      return columns
          .whereType<Map<String, dynamic>>()
          .map(TaskStatusOptionModel.fromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<TaskLabelOptionModel>> getLabelOptions({required String projectId}) async {
    try {
      final response = await _dio.get(ApiConstants.projectLabels(projectId));
      final data = response.data;
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(TaskLabelOptionModel.fromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    required String statusId,
    List<String> assigneeIds = const [],
    List<String> labelIds = const [],
  }) async {
    try {
      final normalizedAssigneeIds = _normalizeUuidList(assigneeIds);
      final normalizedLabelIds = _normalizeUuidList(labelIds);

      if (kDebugMode) {
        debugPrint(
          '[TASK_CREATE] projectId=$projectId assignees=${normalizedAssigneeIds.length} labels=${normalizedLabelIds.length}',
        );
      }

      final response = await _dio.post(
        ApiConstants.projectTasks(projectId),
        data: {
          'title': title,
          'description': description,
          'priority': priority,
          'deadline': deadline?.toIso8601String(),
          'statusId': statusId,
          'assigneeIds': normalizedAssigneeIds,
          'labelIds': normalizedLabelIds,
        },
        options: await _authOptions(),
      );

      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? deadline,
    String? statusId,
    List<String>? assigneeIds,
    List<String>? labelIds,
  }) async {
    try {
      final normalizedAssigneeIds =
          assigneeIds == null ? null : _normalizeUuidList(assigneeIds);
      final normalizedLabelIds = labelIds == null ? null : _normalizeUuidList(labelIds);

      final payload = <String, dynamic>{
        'title': title,
        'description': description,
        'priority': priority,
        'deadline': deadline?.toIso8601String(),
        'assigneeIds': normalizedAssigneeIds,
        'labelIds': normalizedLabelIds,
      }..removeWhere((_, value) => value == null);

      if (kDebugMode) {
        debugPrint(
          '[TASK_UPDATE] taskId=$taskId assignees=${normalizedAssigneeIds?.length ?? 'unchanged'} labels=${normalizedLabelIds?.length ?? 'unchanged'} payload=$payload',
        );
      }

      final response = await _dio.put(
        ApiConstants.taskDetail(taskId),
        data: payload,
        options: await _authOptions(),
      );

      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> moveTaskToStatus({
    required String taskId,
    required String statusId,
  }) async {
    try {
      await _dio.put(
        ApiConstants.taskMoveStatus(taskId),
        data: {'statusId': statusId},
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    try {
      await _dio.delete(
        ApiConstants.taskDetail(taskId),
        options: await _authOptions(),
      );
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
