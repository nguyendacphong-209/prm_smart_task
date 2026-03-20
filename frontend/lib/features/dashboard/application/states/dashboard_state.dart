import 'package:prm_smart_task/features/dashboard/domain/entities/dashboard_project_option.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/user_dashboard.dart';

class DashboardState {
  const DashboardState({
    required this.isLoading,
    required this.isProjectLoading,
    required this.projectOptions,
    this.userDashboard,
    this.projectDashboard,
    this.selectedProjectId,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isProjectLoading;
  final UserDashboard? userDashboard;
  final ProjectDashboard? projectDashboard;
  final List<DashboardProjectOption> projectOptions;
  final String? selectedProjectId;
  final String? errorMessage;

  factory DashboardState.initial() {
    return const DashboardState(
      isLoading: false,
      isProjectLoading: false,
      projectOptions: [],
    );
  }

  DashboardState copyWith({
    bool? isLoading,
    bool? isProjectLoading,
    UserDashboard? userDashboard,
    ProjectDashboard? projectDashboard,
    List<DashboardProjectOption>? projectOptions,
    String? selectedProjectId,
    String? errorMessage,
    bool clearProjectDashboard = false,
    bool clearSelectedProjectId = false,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isProjectLoading: isProjectLoading ?? this.isProjectLoading,
      userDashboard: userDashboard ?? this.userDashboard,
      projectDashboard: clearProjectDashboard
          ? null
          : (projectDashboard ?? this.projectDashboard),
      projectOptions: projectOptions ?? this.projectOptions,
      selectedProjectId: clearSelectedProjectId
          ? null
          : (selectedProjectId ?? this.selectedProjectId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
