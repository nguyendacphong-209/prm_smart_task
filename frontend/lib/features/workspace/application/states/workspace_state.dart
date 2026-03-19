import 'package:prm_smart_task/features/workspace/domain/entities/workspace.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

class WorkspaceState {
  const WorkspaceState({
    required this.isLoading,
    required this.isSubmitting,
    required this.workspaces,
    required this.members,
    this.selectedWorkspace,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final List<Workspace> workspaces;
  final List<WorkspaceMember> members;
  final Workspace? selectedWorkspace;
  final String? errorMessage;
  final String? infoMessage;

  factory WorkspaceState.initial() {
    return const WorkspaceState(
      isLoading: false,
      isSubmitting: false,
      workspaces: [],
      members: [],
    );
  }

  WorkspaceState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<Workspace>? workspaces,
    List<WorkspaceMember>? members,
    Workspace? selectedWorkspace,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
    bool clearSelectedWorkspace = false,
  }) {
    return WorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      workspaces: workspaces ?? this.workspaces,
      members: members ?? this.members,
      selectedWorkspace: clearSelectedWorkspace
          ? null
          : (selectedWorkspace ?? this.selectedWorkspace),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
