# Smart Task Manager - API Endpoints Reference

**Base URL:** `http://localhost:8080` (local) | `https://prm-smart-task-api.onrender.com` (production)

**Authentication:** All endpoints (except Auth) require `Authorization: Bearer {accessToken}` header

---

## 1. AUTH ENDPOINTS

### Register
- **POST** `/api/auth/register`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "fullName": "John Doe",
    "avatarUrl": "https://..."
  }
  ```
- **Response:** `AuthTokenResponse` (accessToken, refreshToken, userId, email, fullName, etc.)

### Login
- **POST** `/api/auth/login`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** `AuthTokenResponse`

### Refresh Token
- **POST** `/api/auth/refresh`
- **Body:**
  ```json
  {
    "refreshToken": "..."
  }
  ```
- **Response:** `AuthTokenResponse` (new tokens issued)

### Logout
- **POST** `/api/auth/logout`
- **Body:**
  ```json
  {
    "refreshToken": "..."
  }
  ```
- **Response:** `{ "message": "Logged out successfully" }`

### Get Current User Profile
- **GET** `/api/auth/me`
- **Response:** `CurrentUserResponse` (id, email, fullName, avatarUrl, createdAt)

### Update Current User Profile
- **PUT** `/api/auth/me`
- **Body:**
  ```json
  {
    "fullName": "Jane Doe",
    "avatarUrl": "https://..."
  }
  ```
- **Response:** `CurrentUserResponse`

### Change Password
- **PUT** `/api/auth/change-password`
- **Body:**
  ```json
  {
    "currentPassword": "old123",
    "newPassword": "new456",
    "confirmNewPassword": "new456"
  }
  ```
- **Response:** `{ "message": "Password changed successfully. Please login again." }`

---

## 2. WORKSPACE ENDPOINTS

### Create Workspace
- **POST** `/api/workspaces`
- **Body:**
  ```json
  {
    "name": "My Team Workspace"
  }
  ```
- **Response:** `WorkspaceResponse` (id, name, ownerId, myRole, createdAt)

### Get My Workspaces (Owner + Participant)
- **GET** `/api/workspaces/my`
- **Response:** `List<WorkspaceResponse>`

### Get Workspace Detail
- **GET** `/api/workspaces/{workspaceId}`
- **Response:** `WorkspaceResponse` (includes myRole: "owner" or "member" or "admin")

### Update Workspace
- **PUT** `/api/workspaces/{workspaceId}`
- **Body:**
  ```json
  {
    "name": "Updated Workspace Name"
  }
  ```
- **Response:** `WorkspaceResponse`
- **Note:** Owner only

### Delete Workspace
- **DELETE** `/api/workspaces/{workspaceId}`
- **Response:** `{ "message": "Workspace deleted successfully" }`
- **Note:** Owner only

### Invite Member
- **POST** `/api/workspaces/{workspaceId}/members/invite`
- **Body:**
  ```json
  {
    "email": "member@example.com",
    "role": "member"
  }
  ```
- **Response:** `WorkspaceMemberResponse`
- **Note:** Owner only

### List Workspace Members
- **GET** `/api/workspaces/{workspaceId}/members`
- **Response:** `List<WorkspaceMemberResponse>` (id, userId, email, fullName, avatarUrl, role)

### Assignee Select Options (by Workspace)
- **GET** `/api/workspaces/{workspaceId}/assignees`
- **Response:** `List<WorkspaceAssigneeOptionResponse>` (userId, email, fullName, avatarUrl)
- **Note:** Dùng để render dropdown/select assignee khi tạo/cập nhật task

### Update Member Role
- **PUT** `/api/workspaces/{workspaceId}/members/{userId}/role`
- **Body:**
  ```json
  {
    "role": "admin"
  }
  ```
- **Response:** `WorkspaceMemberResponse`
- **Note:** Owner only

### Remove Member
- **DELETE** `/api/workspaces/{workspaceId}/members/{userId}`
- **Response:** `{ "message": "Member removed successfully" }`
- **Note:** Owner only

---

## 3. PROJECT ENDPOINTS

### Create Project
- **POST** `/api/workspaces/{workspaceId}/projects`
- **Body:**
  ```json
  {
    "name": "Project Alpha",
    "description": "Mobile app MVP"
  }
  ```
- **Response:** `ProjectResponse` (id, workspaceId, name, description, createdAt)
- **Note:** Owner/Admin only

### List Projects by Workspace
- **GET** `/api/workspaces/{workspaceId}/projects`
- **Response:** `List<ProjectResponse>`

### Update Project
- **PUT** `/api/projects/{projectId}`
- **Body:**
  ```json
  {
    "name": "Updated Name",
    "description": "Updated description"
  }
  ```
- **Response:** `ProjectResponse`
- **Note:** Owner/Admin only

### Delete Project
- **DELETE** `/api/projects/{projectId}`
- **Response:** `{ "message": "Project deleted successfully" }`
- **Note:** Owner/Admin only

---

## 4. TASK ENDPOINTS

### Create Task
- **POST** `/api/projects/{projectId}/tasks`
- **Body:**
  ```json
  {
    "title": "Implement login screen",
    "description": "Flutter UI for login",
    "priority": "high",
    "deadline": "2026-03-30T10:00:00",
    "statusId": "uuid-status-todo",
    "assigneeIds": ["uuid1", "uuid2"],
    "labelIds": ["uuid1"]
  }
  ```
- **Response:** `TaskResponse` (id, projectId, statusId, title, description, priority, deadline, createdBy, createdAt, assignees, labels)
- **Note:** `statusId` là bắt buộc để task luôn xuất hiện trên Kanban board

### List Tasks by Project
- **GET** `/api/projects/{projectId}/tasks`
- **Response:** `List<TaskResponse>`

### Update Task
- **PUT** `/api/tasks/{taskId}`
- **Body:** (all fields optional)
  ```json
  {
    "title": "Updated title",
    "priority": "medium",
    "deadline": "2026-04-01T17:00:00",
    "statusId": "uuid",
    "assigneeIds": ["uuid1"],
    "labelIds": ["uuid1"]
  }
  ```
- **Response:** `TaskResponse`

### Delete Task
- **DELETE** `/api/tasks/{taskId}`
- **Response:** `{ "message": "Task deleted successfully" }`

---

## 5. KANBAN BOARD ENDPOINTS

### Get Kanban Board
- **GET** `/api/projects/{projectId}/kanban`
- **Response:** `KanbanBoardResponse` (projectId, projectName, columns: [id, name, position, tasks])

### Create Task Status
- **POST** `/api/projects/{projectId}/statuses`
- **Body:**
  ```json
  {
    "name": "In Review"
  }
  ```
- **Response:** `KanbanStatusColumnResponse`
- **Note:** Owner/Admin only

### Move Task to Status
- **PUT** `/api/tasks/{taskId}/status`
- **Body:**
  ```json
  {
    "statusId": "uuid"
  }
  ```
- **Response:** `KanbanTaskCardResponse` (id, title, priority, deadline, statusId)
- **Note:** Triggers TASK_STATUS_CHANGED notifications

---

## 6. COLLABORATION ENDPOINTS

### Add Comment
- **POST** `/api/tasks/{taskId}/comments`
- **Body:**
  ```json
  {
    "content": "Please review this @john@example.com"
  }
  ```
- **Response:** `CommentResponse` (id, taskId, userId, userEmail, userFullName, content, mentionedEmails, createdAt)
- **Note:** Mentions auto-extracted from content (format: @email@domain.com)

### List Comments
- **GET** `/api/tasks/{taskId}/comments`
- **Response:** `List<CommentResponse>` (sorted by createdAt ascending)

### Upload Attachment (Mock Storage)
- **POST** `/api/tasks/{taskId}/attachments/mock-upload`
- **Body:** multipart/form-data with file parameter
- **Response:** `AttachmentResponse` (id, taskId, fileName, fileUrl [mock storage path], uploadedAt)
- **Note:** Returns fake URL `/mock-storage/attachments/{uuid}-{filename}`

### List Attachments
- **GET** `/api/tasks/{taskId}/attachments`
- **Response:** `List<AttachmentResponse>` (sorted by uploadedAt descending)

---

## 7. NOTIFICATION ENDPOINTS

### Get My Notifications
- **GET** `/api/notifications`
- **Response:** `List<NotificationResponse>` (id, type, content, isRead, createdAt)
- **Note:** Sorted by createdAt descending (newest first)

### Get Unread Count
- **GET** `/api/notifications/unread-count`
- **Response:** `{ "unreadCount": 5 }`

### Mark Notification as Read
- **PUT** `/api/notifications/{notificationId}/read`
- **Response:** `NotificationResponse`

### Mark All Notifications as Read
- **PUT** `/api/notifications/read-all`
- **Response:** `{ "message": "All notifications marked as read" }`

**Note:** Notifications auto-generated on:
- Task assigned: `TASK_ASSIGNED` type
- Task status changed: `TASK_STATUS_CHANGED` type (sent to all assignees)

---

## 8. DASHBOARD ENDPOINTS

### Get My Dashboard
- **GET** `/api/dashboard/me`
- **Response:** `UserDashboardResponse`
  ```json
  {
    "totalAssignedTasks": 10,
    "completedTasks": 3,
    "overdueTasks": 1,
    "dueSoonTasks": 2,
    "tasksByPriority": {
      "high": 4,
      "medium": 5,
      "low": 1
    },
    "tasksByStatus": {
      "To Do": 5,
      "In Progress": 4,
      "Done": 1
    }
  }
  ```
- **Note:** overdueTasks = past deadline + not completed; dueSoonTasks = within 7 days + not completed

### Get Project Dashboard
- **GET** `/api/dashboard/projects/{projectId}`
- **Response:** `ProjectDashboardResponse`
  ```json
  {
    "projectId": "uuid",
    "projectName": "Project Alpha",
    "completionPercentage": 33.33,
    "totalTasks": 3,
    "completedTasks": 1,
    "tasksByStatus": {
      "To Do": 1,
      "In Progress": 1,
      "Done": 1
    },
    "tasksByPriority": {
      "high": 1,
      "medium": 2
    }
  }
  ```
- **Note:** Completion % = (completedTasks / totalTasks) * 100; Task is "completed" if status.position == max status position

---

## ERROR HANDLING

All error responses follow this format:
```json
{
  "timestamp": "2026-03-19T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Detailed error message",
  "details": {
    "fieldName": "Error for this field"
  }
}
```

**Common status codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation, logic error)
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (insufficient permission)
- `500` - Server Error

---

## QUICK SETUP FOR TESTING

1. **Register** → Get accessToken + refreshToken
2. **Create Workspace** → Get workspaceId
3. **Invite Members** → Get memberIds (or use your own userId)
4. **Create Project** → Get projectId
5. **Create Task Status** → Optional, or use auto-generated defaults
6. **Create Task** → Get taskId, assign members
7. **Move Task** via Kanban → Triggers notifications
8. **Add Comment** → Extract mentions
9. **Check Notifications** → See TASK_ASSIGNED + TASK_STATUS_CHANGED
10. **View Dashboard** → See project progress + personal stats

---

## NOTES FOR FRONTEND

- All UUIDs are case-sensitive
- Timestamps are ISO 8601 format (UTC)
- Email comparison is case-insensitive (system normalizes to lowercase)
- Task "completion" determined by status position (highest position = Done)
- Mention format in comments: `@email@domain.com` (exact email match)
- Fake upload paths: `/mock-storage/attachments/{uuid}-{filename}` (replace with real cloud storage path when ready)
- Pagination not implemented yet (all results returned; handle on FE if needed)
- Real-time updates: use polling (recommended) or upgrade to WebSocket/SSE later
