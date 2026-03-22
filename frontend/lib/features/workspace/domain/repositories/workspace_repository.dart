import 'package:prm_smart_task/features/workspace/domain/entities/workspace.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

abstract class WorkspaceRepository {
  Future<List<Workspace>> getMyWorkspaces();

  Future<Workspace> createWorkspace({required String name});

  Future<Workspace> updateWorkspace({
    required String workspaceId,
    required String name,
  });

  Future<void> deleteWorkspace({required String workspaceId});

  Future<Workspace> getWorkspaceDetail({required String workspaceId});

  Future<List<WorkspaceMember>> getWorkspaceMembers({required String workspaceId});

  Future<List<WorkspaceMember>> getWorkspaceAssignees({required String workspaceId});

  Future<WorkspaceMember> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  });

  Future<WorkspaceMember> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  });

  Future<WorkspaceMember> approveMemberInvitation({
    required String workspaceId,
    required String userId,
  });

  Future<void> rejectMemberInvitation({
    required String workspaceId,
    required String userId,
  });

  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  });
}
