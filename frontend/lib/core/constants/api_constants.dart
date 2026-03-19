class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://prm-smart-task-api.onrender.com';

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
    static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String changePassword = '/api/auth/change-password';

  static const String workspaces = '/api/workspaces';
  static const String myWorkspaces = '/api/workspaces/my';

  static String workspaceDetail(String workspaceId) => '/api/workspaces/$workspaceId';

  static String workspaceMembers(String workspaceId) =>
      '/api/workspaces/$workspaceId/members';

  static String workspaceAssignees(String workspaceId) =>
      '/api/workspaces/$workspaceId/assignees';

  static String workspaceInviteMember(String workspaceId) =>
      '/api/workspaces/$workspaceId/members/invite';

  static String workspaceMemberRole(String workspaceId, String userId) =>
      '/api/workspaces/$workspaceId/members/$userId/role';

  static String workspaceMember(String workspaceId, String userId) =>
      '/api/workspaces/$workspaceId/members/$userId';

  static String workspaceProjects(String workspaceId) =>
      '/api/workspaces/$workspaceId/projects';

  static String projectDetail(String projectId) => '/api/projects/$projectId';

  static String projectTasks(String projectId) => '/api/projects/$projectId/tasks';

    static String projectKanban(String projectId) => '/api/projects/$projectId/kanban';

    static String projectLabels(String projectId) => '/api/projects/$projectId/labels';

    static String projectStatuses(String projectId) => '/api/projects/$projectId/statuses';

  static String taskDetail(String taskId) => '/api/tasks/$taskId';

    static String taskMoveStatus(String taskId) => '/api/tasks/$taskId/status';

    static String taskComments(String taskId) => '/api/tasks/$taskId/comments';

    static String taskAttachments(String taskId) => '/api/tasks/$taskId/attachments';

    static String taskAttachmentMockUpload(String taskId) =>
            '/api/tasks/$taskId/attachments/mock-upload';

    static const String notifications = '/api/notifications';

    static const String notificationUnreadCount = '/api/notifications/unread-count';

    static const String notificationMarkAllRead = '/api/notifications/read-all';

    static String notificationMarkRead(String notificationId) =>
        '/api/notifications/$notificationId/read';
}
