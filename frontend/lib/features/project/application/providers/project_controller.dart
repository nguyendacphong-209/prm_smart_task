import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/project/application/states/project_state.dart';
import 'package:prm_smart_task/features/project/domain/repositories/project_repository.dart';

class ProjectController extends StateNotifier<ProjectState> {
  ProjectController(this._repository) : super(ProjectState.initial());

  final ProjectRepository _repository;

  Future<void> loadProjects({required String workspaceId, bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final projects = await _repository.getProjectsByWorkspace(workspaceId: workspaceId);
      state = state.copyWith(isLoading: false, projects: projects);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createProject({
    required String workspaceId,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final project = await _repository.createProject(
        workspaceId: workspaceId,
        name: name,
        description: description,
      );

      state = state.copyWith(
        isSubmitting: false,
        projects: [project, ...state.projects],
        infoMessage: 'Tạo project thành công',
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

  Future<bool> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final updated = await _repository.updateProject(
        projectId: projectId,
        name: name,
        description: description,
      );

      final nextProjects = state.projects
          .map((item) => item.id == projectId ? updated : item)
          .toList();

      state = state.copyWith(
        isSubmitting: false,
        projects: nextProjects,
        infoMessage: 'Cập nhật project thành công',
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

  Future<bool> deleteProject({required String projectId}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.deleteProject(projectId: projectId);
      state = state.copyWith(
        isSubmitting: false,
        projects: state.projects.where((item) => item.id != projectId).toList(),
        infoMessage: 'Xóa project thành công',
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
