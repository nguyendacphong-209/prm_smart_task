import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/application/states/task_state.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/domain/repositories/task_repository.dart';

class TaskController extends StateNotifier<TaskState> {
  TaskController(this._repository) : super(TaskState.initial());

  final TaskRepository _repository;

  Future<void> loadTasks({required String projectId, bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final tasks = await _repository.getTasksByProject(projectId: projectId);
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadTaskDetail({
    required String projectId,
    required String taskId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearInfo: true,
      clearSelectedTask: true,
    );

    try {
      final task = await _repository.getTaskById(projectId: projectId, taskId: taskId);
      state = state.copyWith(
        isLoading: false,
        selectedTask: task,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<List<TaskStatusOption>> getStatusOptions({required String projectId}) {
    return _repository.getStatusOptions(projectId: projectId);
  }

  Future<List<TaskLabelOption>> getLabelOptions({required String projectId}) {
    return _repository.getLabelOptions(projectId: projectId);
  }

  Future<bool> createTask({
    required String projectId,
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    required String statusId,
    List<String> assigneeIds = const [],
    List<String> labelIds = const [],
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final task = await _repository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
        deadline: deadline,
        statusId: statusId,
        assigneeIds: assigneeIds,
        labelIds: labelIds,
      );

      state = state.copyWith(
        isSubmitting: false,
        tasks: [task, ...state.tasks],
        infoMessage: 'Tạo task thành công',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? deadline,
    String? statusId,
    List<String>? assigneeIds,
    List<String>? labelIds,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final hasStatusUpdate = statusId != null && statusId.isNotEmpty;
      final hasOtherUpdates =
          title != null ||
          description != null ||
          priority != null ||
          deadline != null ||
          assigneeIds != null ||
          labelIds != null;

      if (!hasStatusUpdate && !hasOtherUpdates) {
        state = state.copyWith(
          isSubmitting: false,
          infoMessage: 'Không có thay đổi để cập nhật',
        );
        return true;
      }

      if (hasStatusUpdate) {
        await _repository.moveTaskToStatus(taskId: taskId, statusId: statusId);
      }

      if (hasOtherUpdates) {
        final updated = await _repository.updateTask(
          taskId: taskId,
          title: title,
          description: description,
          priority: priority,
          deadline: deadline,
          statusId: null,
          assigneeIds: assigneeIds,
          labelIds: labelIds,
        );

        final nextTasks = state.tasks
            .map((item) => item.id == taskId ? updated : item)
            .toList();

        state = state.copyWith(
          isSubmitting: false,
          tasks: nextTasks,
          selectedTask: updated,
          infoMessage: 'Cập nhật task thành công',
        );
        return true;
      }

      state = state.copyWith(
        isSubmitting: false,
        infoMessage: 'Cập nhật task thành công',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteTask({required String taskId}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.deleteTask(taskId: taskId);
      state = state.copyWith(
        isSubmitting: false,
        tasks: state.tasks.where((item) => item.id != taskId).toList(),
        clearSelectedTask: true,
        infoMessage: 'Xóa task thành công',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}
