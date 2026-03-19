import 'package:prm_smart_task/features/task/data/datasources/task_remote_data_source.dart';
import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<List<AppTask>> getTasksByProject({required String projectId}) async {
    final tasks = await _remote.getTasksByProject(projectId: projectId);
    return tasks.map((item) => item.toEntity()).toList();
  }

  @override
  Future<AppTask?> getTaskById({
    required String projectId,
    required String taskId,
  }) async {
    final tasks = await getTasksByProject(projectId: projectId);
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  @override
  Future<List<TaskStatusOption>> getStatusOptions({required String projectId}) async {
    final options = await _remote.getStatusOptions(projectId: projectId);
    return options.map((item) => item.toEntity()).toList();
  }

  @override
  Future<List<TaskLabelOption>> getLabelOptions({required String projectId}) async {
    final options = await _remote.getLabelOptions(projectId: projectId);
    return options.map((item) => item.toEntity()).toList();
  }

  @override
  Future<AppTask> createTask({
    required String projectId,
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    required String statusId,
    List<String> assigneeIds = const [],
    List<String> labelIds = const [],
  }) async {
    final task = await _remote.createTask(
      projectId: projectId,
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      statusId: statusId,
      assigneeIds: assigneeIds,
      labelIds: labelIds,
    );
    return task.toEntity();
  }

  @override
  Future<AppTask> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? deadline,
    String? statusId,
    List<String>? assigneeIds,
    List<String>? labelIds,
  }) async {
    final task = await _remote.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      statusId: statusId,
      assigneeIds: assigneeIds,
      labelIds: labelIds,
    );

    return task.toEntity();
  }

  @override
  Future<void> moveTaskToStatus({
    required String taskId,
    required String statusId,
  }) {
    return _remote.moveTaskToStatus(taskId: taskId, statusId: statusId);
  }

  @override
  Future<void> deleteTask({required String taskId}) {
    return _remote.deleteTask(taskId: taskId);
  }
}
