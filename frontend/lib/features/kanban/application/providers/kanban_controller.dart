import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/kanban/application/states/kanban_state.dart';
import 'package:prm_smart_task/features/kanban/domain/repositories/kanban_repository.dart';

class KanbanController extends StateNotifier<KanbanState> {
  KanbanController(this._repository) : super(KanbanState.initial());

  final KanbanRepository _repository;

  Future<void> loadBoard({required String projectId, bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final board = await _repository.getBoard(projectId: projectId);
      state = state.copyWith(isLoading: false, board: board);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createStatus({required String projectId, required String name}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.createStatus(projectId: projectId, name: name);
      final board = await _repository.getBoard(projectId: projectId);

      state = state.copyWith(
        isSubmitting: false,
        board: board,
        infoMessage: 'Tạo status thành công',
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

  Future<bool> moveTaskToStatus({
    required String projectId,
    required String taskId,
    required String statusId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.moveTaskToStatus(taskId: taskId, statusId: statusId);
      final board = await _repository.getBoard(projectId: projectId);

      state = state.copyWith(
        isSubmitting: false,
        board: board,
        infoMessage: 'Đã cập nhật trạng thái task',
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
}
