class TaskNotification {
  const TaskNotification({
    required this.id,
    required this.type,
    required this.content,
    required this.isRead,
    this.workspaceId,
    this.targetUserId,
    this.createdAt,
  });

  final String id;
  final String type;
  final String content;
  final bool isRead;
  final String? workspaceId;
  final String? targetUserId;
  final DateTime? createdAt;

  bool get isTaskAssigned => type.toUpperCase() == 'TASK_ASSIGNED';

  bool get isTaskStatusChanged => type.toUpperCase() == 'TASK_STATUS_CHANGED';

    bool get isWorkspaceInviteApprovalRequest =>
      type.toUpperCase() == 'WORKSPACE_INVITE_APPROVAL_REQUEST';

    bool get isWorkspaceInvitationApproved =>
      type.toUpperCase() == 'WORKSPACE_INVITATION_APPROVED';

    bool get isWorkspaceInvitationRejected =>
      type.toUpperCase() == 'WORKSPACE_INVITATION_REJECTED';

    bool get isWorkspaceInvited => type.toUpperCase() == 'WORKSPACE_INVITED';
}
