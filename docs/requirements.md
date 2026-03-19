# Smart Task Manager - Requirements

## Project Overview
Smart Task Manager is a collaborative task management API built with Spring Boot. It enables teams to organize work using workspaces, projects, and tasks with role-based access control.

## Features

### Authentication
- User registration with email, username, and password
- JWT-based login/logout
- Secure password hashing with BCrypt

### Workspaces
- Create and manage workspaces
- Invite/remove members
- Role-based access: OWNER, ADMIN, MEMBER

### Projects
- Create projects within workspaces
- Track project status (ACTIVE, ARCHIVED)
- List all projects in a workspace

### Tasks
- Create tasks with title, description, status, priority, and deadline
- Assign tasks to workspace members
- Filter tasks by status: TODO, IN_PROGRESS, IN_REVIEW, DONE
- Priority levels: LOW, MEDIUM, HIGH, URGENT

### Comments
- Add comments to tasks
- Edit and delete own comments
- Notifications triggered on new comments

### Notifications
- Automatic notifications for task assignments, updates, and comments
- Mark individual or all notifications as read
- Filter unread notifications

## Tech Stack
- Java 17
- Spring Boot 3.2.5
- Spring Data JPA + Hibernate
- PostgreSQL
- JWT Authentication (JJWT 0.11.5)
- Lombok
- Spring Security

## API Endpoints Overview

### Auth
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login and receive JWT

### Workspaces
- `POST /api/workspaces` - Create workspace
- `GET /api/workspaces` - List user workspaces
- `GET /api/workspaces/{id}` - Get workspace
- `PUT /api/workspaces/{id}` - Update workspace
- `DELETE /api/workspaces/{id}` - Delete workspace
- `POST /api/workspaces/{id}/members/{memberId}` - Add member
- `DELETE /api/workspaces/{id}/members/{memberId}` - Remove member

### Projects
- `POST /api/projects` - Create project
- `GET /api/projects/{id}` - Get project
- `GET /api/projects/workspace/{workspaceId}` - List workspace projects
- `PUT /api/projects/{id}` - Update project
- `DELETE /api/projects/{id}` - Delete project

### Tasks
- `POST /api/tasks` - Create task
- `GET /api/tasks/{id}` - Get task
- `GET /api/tasks/project/{projectId}` - List project tasks
- `GET /api/tasks/project/{projectId}/status/{status}` - Filter by status (Kanban)
- `GET /api/tasks/assignee/{assigneeId}` - List tasks assigned to a user
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task
- `PATCH /api/tasks/{id}/assign/{assigneeId}` - Assign task
- `PATCH /api/tasks/{id}/status` - Update task status

### Comments
- `POST /api/comments` - Add comment
- `GET /api/comments/task/{taskId}` - List task comments
- `PUT /api/comments/{id}` - Update comment
- `DELETE /api/comments/{id}` - Delete comment

### Notifications
- `GET /api/notifications` - Get all notifications
- `GET /api/notifications/unread` - Get unread notifications
- `GET /api/notifications/unread-count` - Get unread notification count
- `PATCH /api/notifications/{id}/read` - Mark as read
- `PATCH /api/notifications/read-all` - Mark all as read
