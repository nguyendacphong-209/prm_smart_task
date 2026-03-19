import 'package:prm_smart_task/features/project/domain/entities/project.dart';

class ProjectState {
  const ProjectState({
    required this.isLoading,
    required this.isSubmitting,
    required this.projects,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final List<Project> projects;
  final String? errorMessage;
  final String? infoMessage;

  factory ProjectState.initial() {
    return const ProjectState(
      isLoading: false,
      isSubmitting: false,
      projects: [],
    );
  }

  ProjectState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<Project>? projects,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return ProjectState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      projects: projects ?? this.projects,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
