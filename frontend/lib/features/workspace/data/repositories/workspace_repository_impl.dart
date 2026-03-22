import 'package:prm_smart_task/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import 'package:prm_smart_task/features/workspace/domain/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  const WorkspaceRepositoryImpl(this._remote);

  final WorkspaceRemoteDataSource _remote;

  @override
  Future<List<Workspace>> getMyWorkspaces() async {
    final models = await _remote.getMyWorkspaces();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Workspace> createWorkspace({required String name}) async {
    final model = await _remote.createWorkspace(name: name);
    return model.toEntity();
  }

  @override
  Future<Workspace> updateWorkspace({
    required String workspaceId,
    required String name,
  }) async {
    final model = await _remote.updateWorkspace(
      workspaceId: workspaceId,
      name: name,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteWorkspace({required String workspaceId}) async {
    await _remote.deleteWorkspace(workspaceId: workspaceId);
  }

  @override
  Future<Workspace> getWorkspaceDetail({required String workspaceId}) async {
    final model = await _remote.getWorkspaceDetail(workspaceId: workspaceId);
    return model.toEntity();
  }

  @override
  Future<List<WorkspaceMember>> getWorkspaceMembers({
    required String workspaceId,
  }) async {
    final models = await _remote.getWorkspaceMembers(workspaceId: workspaceId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<WorkspaceMember>> getWorkspaceAssignees({
    required String workspaceId,
  }) async {
    final models = await _remote.getWorkspaceAssignees(workspaceId: workspaceId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<WorkspaceMember> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    final model = await _remote.inviteMember(
      workspaceId: workspaceId,
      email: email,
      role: role,
    );
    return model.toEntity();
  }

  @override
  Future<WorkspaceMember> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    final model = await _remote.updateMemberRole(
      workspaceId: workspaceId,
      userId: userId,
      role: role,
    );
    return model.toEntity();
  }

  @override
  Future<WorkspaceMember> approveMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    final model = await _remote.approveMemberInvitation(
      workspaceId: workspaceId,
      userId: userId,
    );
    return model.toEntity();
  }

  @override
  Future<void> rejectMemberInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    await _remote.rejectMemberInvitation(
      workspaceId: workspaceId,
      userId: userId,
    );
  }

  @override
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    await _remote.removeMember(workspaceId: workspaceId, userId: userId);
  }
}
