package com.example.prm_smart_task.service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.kanban.CreateTaskStatusRequest;
import com.example.prm_smart_task.dto.kanban.KanbanBoardResponse;
import com.example.prm_smart_task.dto.kanban.KanbanStatusColumnResponse;
import com.example.prm_smart_task.dto.kanban.KanbanTaskCardResponse;
import com.example.prm_smart_task.dto.kanban.MoveTaskStatusRequest;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.entity.Project;
import com.example.prm_smart_task.entity.Task;
import com.example.prm_smart_task.entity.TaskStatus;
import com.example.prm_smart_task.entity.Workspace;
import com.example.prm_smart_task.entity.WorkspaceMember;
import com.example.prm_smart_task.exception.BadRequestException;
import com.example.prm_smart_task.exception.UnauthorizedException;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.repository.ProjectRepository;
import com.example.prm_smart_task.repository.TaskRepository;
import com.example.prm_smart_task.repository.TaskAssignmentRepository;
import com.example.prm_smart_task.repository.TaskStatusRepository;
import com.example.prm_smart_task.repository.WorkspaceMemberRepository;

@Service
public class KanbanService {

    private final AppUserRepository appUserRepository;
    private final ProjectRepository projectRepository;
    private final TaskRepository taskRepository;
    private final TaskAssignmentRepository taskAssignmentRepository;
    private final TaskStatusRepository taskStatusRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final NotificationService notificationService;

    public KanbanService(
            AppUserRepository appUserRepository,
            ProjectRepository projectRepository,
            TaskRepository taskRepository,
            TaskAssignmentRepository taskAssignmentRepository,
            TaskStatusRepository taskStatusRepository,
            WorkspaceMemberRepository workspaceMemberRepository,
            NotificationService notificationService) {
        this.appUserRepository = appUserRepository;
        this.projectRepository = projectRepository;
        this.taskRepository = taskRepository;
        this.taskAssignmentRepository = taskAssignmentRepository;
        this.taskStatusRepository = taskStatusRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.notificationService = notificationService;
    }

    @Transactional(readOnly = true)
    public KanbanBoardResponse getBoard(String currentEmail, UUID projectId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = getProject(projectId);
        ensureWorkspaceMember(currentUser, project.getWorkspace().getId());

        List<TaskStatus> statuses = taskStatusRepository.findByProjectIdOrderByPositionAsc(projectId);
        List<Task> tasks = taskRepository.findByProjectId(projectId);

        Map<UUID, List<Task>> tasksByStatus = tasks.stream()
                .filter(task -> task.getStatus() != null)
                .collect(Collectors.groupingBy(task -> task.getStatus().getId()));

        List<KanbanStatusColumnResponse> columns = statuses.stream()
                .map(status -> new KanbanStatusColumnResponse(
                        status.getId(),
                        status.getName(),
                        status.getPosition(),
                        tasksByStatus.getOrDefault(status.getId(), List.of())
                                .stream()
                                .map(this::mapTaskCard)
                                .toList()))
                .toList();

        return new KanbanBoardResponse(project.getId(), project.getName(), columns);
    }

    @Transactional
    public KanbanStatusColumnResponse createStatus(String currentEmail, UUID projectId, CreateTaskStatusRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = getProject(projectId);
        ensureCanManageKanban(currentUser, project.getWorkspace());

        String statusName = request.name().trim();
        if (taskStatusRepository.existsByProjectIdAndNameIgnoreCase(projectId, statusName)) {
            throw new BadRequestException("Status name already exists in this project");
        }

        int nextPosition = taskStatusRepository.findTopByProjectIdOrderByPositionDesc(projectId)
                .map(taskStatus -> taskStatus.getPosition() + 1)
                .orElse(1);

        TaskStatus taskStatus = new TaskStatus();
        taskStatus.setProject(project);
        taskStatus.setName(statusName);
        taskStatus.setPosition(nextPosition);

        TaskStatus savedStatus = taskStatusRepository.save(taskStatus);
        return new KanbanStatusColumnResponse(
                savedStatus.getId(),
                savedStatus.getName(),
                savedStatus.getPosition(),
                List.of());
    }

    @Transactional
    public KanbanTaskCardResponse moveTaskToStatus(String currentEmail, UUID taskId, MoveTaskStatusRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new BadRequestException("Task not found"));

        UUID projectId = task.getProject().getId();
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        TaskStatus status = taskStatusRepository.findByIdAndProjectId(request.statusId(), projectId)
                .orElseThrow(() -> new BadRequestException("Status not found in this project"));

        String oldStatusName = task.getStatus() == null ? "No Status" : task.getStatus().getName();
        String newStatusName = status.getName();
        boolean statusChanged = task.getStatus() == null || !task.getStatus().getId().equals(status.getId());

        task.setStatus(status);
        Task updatedTask = taskRepository.save(task);

        if (statusChanged) {
            notifyTaskStatusChanged(updatedTask, oldStatusName, newStatusName, currentUser);
        }

        return mapTaskCard(updatedTask);
    }

    private void notifyTaskStatusChanged(Task task, String oldStatusName, String newStatusName, AppUser changedBy) {
        List<AppUser> recipients = taskAssignmentRepository.findByTaskId(task.getId())
                .stream()
                .map(taskAssignment -> taskAssignment.getUser())
                .toList();

        for (AppUser recipient : recipients) {
            notificationService.notifyTaskStatusChanged(recipient, task, oldStatusName, newStatusName, changedBy);
        }
    }

    private AppUser getUserByEmail(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        return appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private Project getProject(UUID projectId) {
        return projectRepository.findById(projectId)
                .orElseThrow(() -> new BadRequestException("Project not found"));
    }

    private void ensureWorkspaceMember(AppUser currentUser, UUID workspaceId) {
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }
    }

    private void ensureCanManageKanban(AppUser currentUser, Workspace workspace) {
        if (workspace.getOwner().getId().equals(currentUser.getId())) {
            return;
        }

        WorkspaceMember member = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspace.getId(), currentUser.getId())
                .orElseThrow(() -> new UnauthorizedException("You are not a member of this workspace"));

        if (!"admin".equalsIgnoreCase(member.getRole())) {
            throw new UnauthorizedException("Only workspace owner or admin can manage Kanban status");
        }
    }

    private KanbanTaskCardResponse mapTaskCard(Task task) {
        return new KanbanTaskCardResponse(
                task.getId(),
                task.getTitle(),
                task.getPriority(),
                task.getDeadline(),
                task.getStatus() == null ? null : task.getStatus().getId());
    }
}
