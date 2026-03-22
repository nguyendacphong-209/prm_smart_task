import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/workspace/application/states/workspace_state.dart';
import 'package:prm_smart_task/features/workspace/domain/repositories/workspace_repository.dart';

class WorkspaceController extends StateNotifier<WorkspaceState> {
  WorkspaceController(this._repository) : super(WorkspaceState.initial());

  final WorkspaceRepository _repository;

  Future<void> loadMyWorkspaces({bool forceReload = false}) async {
    if (state.isLoading && !forceReload) return;

    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final workspaces = await _repository.getMyWorkspaces();
      state = state.copyWith(
        isLoading: false,
        workspaces: workspaces,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createWorkspace({required String name}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final created = await _repository.createWorkspace(name: name);
      state = state.copyWith(
        isSubmitting: false,
        workspaces: [created, ...state.workspaces],
        infoMessage: 'Tạo workspace thành công',
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

  Future<bool> updateWorkspace({
    required String workspaceId,
    required String name,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final updated = await _repository.updateWorkspace(
        workspaceId: workspaceId,
        name: name,
      );

      final nextWorkspaces = state.workspaces
          .map((item) => item.id == workspaceId ? updated : item)
          .toList();

      state = state.copyWith(
        isSubmitting: false,
        workspaces: nextWorkspaces,
        selectedWorkspace:
            state.selectedWorkspace?.id == workspaceId ? updated : state.selectedWorkspace,
        infoMessage: 'Cập nhật workspace thành công',
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

  Future<bool> deleteWorkspace({required String workspaceId}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.deleteWorkspace(workspaceId: workspaceId);

      state = state.copyWith(
        isSubmitting: false,
        workspaces: state.workspaces.where((item) => item.id != workspaceId).toList(),
        clearSelectedWorkspace: state.selectedWorkspace?.id == workspaceId,
        infoMessage: 'Xóa workspace thành công',
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

  Future<void> loadWorkspaceDetail({required String workspaceId}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final workspace = await _repository.getWorkspaceDetail(workspaceId: workspaceId);
      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);

      state = state.copyWith(
        isLoading: false,
        selectedWorkspace: workspace,
        members: members,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      final invitedMember = await _repository.inviteMember(
        workspaceId: workspaceId,
        email: email,
        role: role,
      );

      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);
      state = state.copyWith(
        isSubmitting: false,
        members: members,
        infoMessage: invitedMember.isPendingOwnerApproval
            ? 'Đã gửi lời mời. Thành viên sẽ vào workspace sau khi owner duyệt.'
            : 'Mời thành viên thành công',
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

  Future<bool> approveMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.approveMemberInvitation(
        workspaceId: workspaceId,
        userId: userId,
      );

      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);
      state = state.copyWith(
        isSubmitting: false,
        members: members,
        infoMessage: 'Đã duyệt lời mời thành viên',
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

  Future<bool> rejectMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.rejectMemberInvitation(
        workspaceId: workspaceId,
        userId: userId,
      );

      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);
      state = state.copyWith(
        isSubmitting: false,
        members: members,
        infoMessage: 'Đã từ chối lời mời thành viên',
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

  Future<bool> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.updateMemberRole(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
      );

      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);
      state = state.copyWith(
        isSubmitting: false,
        members: members,
        infoMessage: 'Cập nhật vai trò thành công',
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

  Future<bool> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);

    try {
      await _repository.removeMember(workspaceId: workspaceId, userId: userId);

      final members = await _repository.getWorkspaceMembers(workspaceId: workspaceId);
      state = state.copyWith(
        isSubmitting: false,
        members: members,
        infoMessage: 'Đã xóa thành viên',
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
