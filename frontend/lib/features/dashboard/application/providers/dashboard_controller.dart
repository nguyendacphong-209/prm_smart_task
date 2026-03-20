import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/dashboard/application/states/dashboard_state.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/dashboard_project_option.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._repository) : super(DashboardState.initial());

  final DashboardRepository _repository;

  Future<void> loadDashboard({bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final userDashboardFuture = _repository.getMyDashboard();
      final projectOptionsFuture = _repository.getProjectOptions();

      final userDashboard = await userDashboardFuture;
      final projectOptions = await projectOptionsFuture;

      final selectedProjectId = _resolveSelectedProjectId(projectOptions);
      ProjectDashboard? projectDashboard;
      if (selectedProjectId != null) {
        projectDashboard = await _repository.getProjectDashboard(
          projectId: selectedProjectId,
        );
      }

      state = state.copyWith(
        isLoading: false,
        userDashboard: userDashboard,
        projectOptions: projectOptions,
        selectedProjectId: selectedProjectId,
        projectDashboard: projectDashboard,
        clearSelectedProjectId: selectedProjectId == null,
        clearProjectDashboard: selectedProjectId == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> selectProject(String projectId) async {
    if (projectId == state.selectedProjectId && state.projectDashboard != null) {
      return;
    }

    state = state.copyWith(
      selectedProjectId: projectId,
      isProjectLoading: true,
      clearError: true,
    );

    try {
      final projectDashboard = await _repository.getProjectDashboard(
        projectId: projectId,
      );

      state = state.copyWith(
        isProjectLoading: false,
        projectDashboard: projectDashboard,
      );
    } catch (e) {
      state = state.copyWith(
        isProjectLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String? _resolveSelectedProjectId(List<DashboardProjectOption> projectOptions) {
    final existing = state.selectedProjectId;
    if (existing != null &&
        projectOptions.any((option) => option.projectId == existing)) {
      return existing;
    }

    if (projectOptions.isEmpty) {
      return null;
    }

    return projectOptions.first.projectId;
  }
}
