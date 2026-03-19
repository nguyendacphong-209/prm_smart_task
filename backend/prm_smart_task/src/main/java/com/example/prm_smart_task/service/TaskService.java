package com.example.prm_smart_task.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.task.CreateTaskRequest;
import com.example.prm_smart_task.dto.task.TaskAssigneeResponse;
import com.example.prm_smart_task.dto.task.TaskLabelResponse;
import com.example.prm_smart_task.dto.task.TaskResponse;
import com.example.prm_smart_task.dto.task.UpdateTaskRequest;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.entity.Label;
import com.example.prm_smart_task.entity.Project;
import com.example.prm_smart_task.entity.Task;
import com.example.prm_smart_task.entity.TaskAssignment;
import com.example.prm_smart_task.entity.TaskStatus;
import com.example.prm_smart_task.entity.WorkspaceMember;
import com.example.prm_smart_task.exception.BadRequestException;
import com.example.prm_smart_task.exception.UnauthorizedException;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.repository.LabelRepository;
import com.example.prm_smart_task.repository.ProjectRepository;
import com.example.prm_smart_task.repository.TaskAssignmentRepository;
import com.example.prm_smart_task.repository.TaskRepository;
import com.example.prm_smart_task.repository.TaskStatusRepository;
import com.example.prm_smart_task.repository.WorkspaceMemberRepository;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final TaskStatusRepository taskStatusRepository;
    private final TaskAssignmentRepository taskAssignmentRepository;
    private final LabelRepository labelRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final AppUserRepository appUserRepository;
    private final NotificationService notificationService;

    public TaskService(
            TaskRepository taskRepository,
            ProjectRepository projectRepository,
            TaskStatusRepository taskStatusRepository,
            TaskAssignmentRepository taskAssignmentRepository,
            LabelRepository labelRepository,
            WorkspaceMemberRepository workspaceMemberRepository,
            AppUserRepository appUserRepository,
            NotificationService notificationService) {
        this.taskRepository = taskRepository;
        this.projectRepository = projectRepository;
        this.taskStatusRepository = taskStatusRepository;
        this.taskAssignmentRepository = taskAssignmentRepository;
        this.labelRepository = labelRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.appUserRepository = appUserRepository;
        this.notificationService = notificationService;
    }

    @Transactional
    public TaskResponse createTask(String currentEmail, UUID projectId, CreateTaskRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = getProject(projectId);
        ensureWorkspaceMember(currentUser, project.getWorkspace().getId());

        Task task = new Task();
        task.setProject(project);
        task.setTitle(request.title().trim());
        task.setDescription(normalizeNullableText(request.description()));
        task.setPriority(normalizeNullableText(request.priority()));
        task.setDeadline(request.deadline());
        task.setCreatedBy(currentUser);

        if (request.statusId() != null) {
            TaskStatus status = taskStatusRepository.findByIdAndProjectId(request.statusId(), projectId)
                    .orElseThrow(() -> new BadRequestException("Task status not found in this project"));
            task.setStatus(status);
        }

        applyLabels(task, projectId, request.labelIds());
        Task savedTask = taskRepository.save(task);
        applyAssignees(savedTask, project.getWorkspace().getId(), request.assigneeIds(), currentUser);

        return mapTask(savedTask);
    }

    @Transactional(readOnly = true)
    public List<TaskResponse> getTasksByProject(String currentEmail, UUID projectId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = getProject(projectId);
        ensureWorkspaceMember(currentUser, project.getWorkspace().getId());

        return taskRepository.findByProjectId(projectId)
                .stream()
                .map(this::mapTask)
                .toList();
    }

    @Transactional
    public TaskResponse updateTask(String currentEmail, UUID taskId, UpdateTaskRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        if (request.title() != null) {
            String normalizedTitle = request.title().trim();
            if (normalizedTitle.isBlank()) {
                throw new BadRequestException("Task title must not be blank");
            }
            task.setTitle(normalizedTitle);
        }

        if (request.description() != null) {
            task.setDescription(normalizeNullableText(request.description()));
        }

        if (request.priority() != null) {
            task.setPriority(normalizeNullableText(request.priority()));
        }

        if (request.deadline() != null) {
            task.setDeadline(request.deadline());
        }

        if (request.statusId() != null) {
            String oldStatusName = task.getStatus() == null ? "No Status" : task.getStatus().getName();
            TaskStatus status = taskStatusRepository.findByIdAndProjectId(request.statusId(), task.getProject().getId())
                    .orElseThrow(() -> new BadRequestException("Task status not found in this project"));

            String newStatusName = status.getName();
            boolean statusChanged = task.getStatus() == null || !task.getStatus().getId().equals(status.getId());
            task.setStatus(status);

            if (statusChanged) {
                notifyTaskStatusChanged(task, oldStatusName, newStatusName, currentUser);
            }
        }

        if (request.labelIds() != null) {
            applyLabels(task, task.getProject().getId(), request.labelIds());
        }

        Task updatedTask = taskRepository.save(task);

        if (request.assigneeIds() != null) {
            applyAssignees(updatedTask, updatedTask.getProject().getWorkspace().getId(), request.assigneeIds(), currentUser);
        }

        return mapTask(updatedTask);
    }

    @Transactional
    public ApiMessageResponse deleteTask(String currentEmail, UUID taskId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        taskRepository.delete(task);
        return new ApiMessageResponse("Task deleted successfully");
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

    private Task getTask(UUID taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new BadRequestException("Task not found"));
    }

    private void ensureWorkspaceMember(AppUser currentUser, UUID workspaceId) {
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }
    }

    private void applyLabels(Task task, UUID projectId, List<UUID> labelIds) {
        if (labelIds == null) {
            return;
        }

        Set<Label> labels = new HashSet<>();
        for (UUID labelId : new HashSet<>(labelIds)) {
            Label label = labelRepository.findById(labelId)
                    .orElseThrow(() -> new BadRequestException("Label not found"));
            if (!label.getProject().getId().equals(projectId)) {
                throw new BadRequestException("Label does not belong to this project");
            }
            labels.add(label);
        }
        task.setLabels(labels);
    }

    private void applyAssignees(Task task, UUID workspaceId, List<UUID> assigneeIds, AppUser assignedBy) {
        if (assigneeIds == null) {
            return;
        }

        Set<UUID> existingAssigneeIds = taskAssignmentRepository.findByTaskId(task.getId())
                .stream()
                .map(assignment -> assignment.getUser().getId())
                .collect(java.util.stream.Collectors.toSet());

        taskAssignmentRepository.deleteByTaskId(task.getId());
        if (assigneeIds.isEmpty()) {
            return;
        }

        Set<UUID> uniqueUserIds = new HashSet<>(assigneeIds);
        for (UUID userId : uniqueUserIds) {
            WorkspaceMember member = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                    .orElseThrow(() -> new BadRequestException("Assignee must be a member of workspace"));

            TaskAssignment assignment = new TaskAssignment();
            assignment.setTask(task);
            assignment.setUser(member.getUser());
            taskAssignmentRepository.save(assignment);

            if (!existingAssigneeIds.contains(userId)) {
                notificationService.notifyTaskAssigned(member.getUser(), task, assignedBy);
            }
        }
    }

    private void notifyTaskStatusChanged(Task task, String oldStatusName, String newStatusName, AppUser changedBy) {
        List<AppUser> recipients = taskAssignmentRepository.findByTaskId(task.getId())
                .stream()
                .map(TaskAssignment::getUser)
                .toList();

        for (AppUser recipient : recipients) {
            notificationService.notifyTaskStatusChanged(recipient, task, oldStatusName, newStatusName, changedBy);
        }
    }

    private String normalizeNullableText(String value) {
        if (value == null) {
            return null;
        }

        String normalizedValue = value.trim();
        return normalizedValue.isBlank() ? null : normalizedValue;
    }

    private TaskResponse mapTask(Task task) {
        List<TaskAssigneeResponse> assignees = taskAssignmentRepository.findByTaskId(task.getId())
                .stream()
                .map(taskAssignment -> new TaskAssigneeResponse(
                        taskAssignment.getUser().getId(),
                        taskAssignment.getUser().getEmail(),
                        taskAssignment.getUser().getFullName(),
                        taskAssignment.getUser().getAvatarUrl()))
                .toList();

        List<TaskLabelResponse> labels = new ArrayList<>(task.getLabels())
                .stream()
                .map(label -> new TaskLabelResponse(
                        label.getId(),
                        label.getName(),
                        label.getColor()))
                .toList();

        return new TaskResponse(
                task.getId(),
                task.getProject().getId(),
                task.getStatus() == null ? null : task.getStatus().getId(),
                task.getTitle(),
                task.getDescription(),
                task.getPriority(),
                task.getDeadline(),
                task.getCreatedBy() == null ? null : task.getCreatedBy().getId(),
                task.getCreatedAt(),
                assignees,
                labels);
    }
}
