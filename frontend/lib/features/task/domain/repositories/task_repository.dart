import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';

abstract class TaskRepository {
  Future<List<AppTask>> getTasksByProject({required String projectId});

  Future<AppTask?> getTaskById({
    required String projectId,
    required String taskId,
  });

  Future<List<TaskStatusOption>> getStatusOptions({required String projectId});

  Future<List<TaskLabelOption>> getLabelOptions({required String projectId});

  Future<AppTask> createTask({
    required String projectId,
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    required String statusId,
    List<String> assigneeIds,
    List<String> labelIds,
  });

  Future<AppTask> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? deadline,
    String? statusId,
    List<String>? assigneeIds,
    List<String>? labelIds,
  });

  Future<void> moveTaskToStatus({
    required String taskId,
    required String statusId,
  });

  Future<void> deleteTask({required String taskId});
}
