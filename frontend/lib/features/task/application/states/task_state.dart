import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';

class TaskState {
  const TaskState({
    required this.isLoading,
    required this.isSubmitting,
    required this.tasks,
    this.selectedTask,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final List<AppTask> tasks;
  final AppTask? selectedTask;
  final String? errorMessage;
  final String? infoMessage;

  factory TaskState.initial() {
    return const TaskState(
      isLoading: false,
      isSubmitting: false,
      tasks: [],
    );
  }

  TaskState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<AppTask>? tasks,
    AppTask? selectedTask,
    String? errorMessage,
    String? infoMessage,
    bool clearSelectedTask = false,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      tasks: tasks ?? this.tasks,
      selectedTask: clearSelectedTask
          ? null
          : (selectedTask ?? this.selectedTask),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
