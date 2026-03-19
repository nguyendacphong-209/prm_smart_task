package com.smarttask.service.impl;

import com.smarttask.dto.request.TaskRequest;
import com.smarttask.dto.response.TaskResponse;
import com.smarttask.entity.Project;
import com.smarttask.entity.Task;
import com.smarttask.entity.User;
import com.smarttask.enums.NotificationType;
import com.smarttask.enums.TaskStatus;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.ProjectRepository;
import com.smarttask.repository.TaskRepository;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.NotificationService;
import com.smarttask.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskServiceImpl implements TaskService {

    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public TaskResponse createTask(TaskRequest request, UUID userId) {
        Project project = projectRepository.findById(request.getProjectId())
            .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        User assignee = null;
        if (request.getAssigneeId() != null) {
            assignee = userRepository.findById(request.getAssigneeId())
                .orElseThrow(() -> new ResourceNotFoundException("Assignee not found"));
        }
        Task task = Task.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .status(request.getStatus() != null ? request.getStatus() : TaskStatus.TODO)
            .priority(request.getPriority())
            .deadline(request.getDeadline())
            .project(project)
            .assignee(assignee)
            .build();
        Task savedTask = taskRepository.save(task);
        if (assignee != null) {
            notificationService.createNotification(
                NotificationType.TASK_ASSIGNED,
                "You have been assigned to task: " + savedTask.getTitle(),
                assignee.getId(),
                savedTask.getId()
            );
        }
        return toResponse(savedTask);
    }

    @Override
    public TaskResponse getTask(UUID id) {
        return toResponse(taskRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found")));
    }

    @Override
    public List<TaskResponse> getProjectTasks(UUID projectId) {
        return taskRepository.findByProjectId(projectId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getProjectTasksByStatus(UUID projectId, TaskStatus status) {
        return taskRepository.findByProjectIdAndStatus(projectId, status)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getAssigneeTasks(UUID assigneeId) {
        return taskRepository.findByAssigneeId(assigneeId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public TaskResponse updateTask(UUID id, TaskRequest request) {
        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        if (request.getStatus() != null) task.setStatus(request.getStatus());
        if (request.getPriority() != null) task.setPriority(request.getPriority());
        task.setDeadline(request.getDeadline());
        if (request.getAssigneeId() != null) {
            User assignee = userRepository.findById(request.getAssigneeId())
                .orElseThrow(() -> new ResourceNotFoundException("Assignee not found"));
            boolean assigneeChanged = task.getAssignee() == null || !task.getAssignee().getId().equals(assignee.getId());
            task.setAssignee(assignee);
            if (assigneeChanged) {
                notificationService.createNotification(
                    NotificationType.TASK_ASSIGNED,
                    "You have been assigned to task: " + task.getTitle(),
                    assignee.getId(),
                    task.getId()
                );
            }
        } else {
            task.setAssignee(null);
        }
        return toResponse(taskRepository.save(task));
    }

    @Override
    @Transactional
    public void deleteTask(UUID id) {
        Task task = taskRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        taskRepository.delete(task);
    }

    @Override
    @Transactional
    public void assignTask(UUID taskId, UUID assigneeId, UUID userId) {
        Task task = taskRepository.findById(taskId)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        User assignee = userRepository.findById(assigneeId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        // Only notify if the assignee is actually changing
        boolean assigneeChanged = task.getAssignee() == null || !task.getAssignee().getId().equals(assigneeId);
        task.setAssignee(assignee);
        taskRepository.save(task);
        if (assigneeChanged) {
            notificationService.createNotification(
                NotificationType.TASK_ASSIGNED,
                "You have been assigned to task: " + task.getTitle(),
                assignee.getId(),
                task.getId()
            );
        }
    }

    @Override
    @Transactional
    public TaskResponse updateTaskStatus(UUID taskId, TaskStatus status, UUID userId) {
        Task task = taskRepository.findById(taskId)
            .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        task.setStatus(status);
        task = taskRepository.save(task);
        if (task.getAssignee() != null) {
            notificationService.createNotification(
                NotificationType.TASK_UPDATED,
                "Task status updated to " + status + ": " + task.getTitle(),
                task.getAssignee().getId(),
                task.getId()
            );
        }
        return toResponse(task);
    }

    private TaskResponse toResponse(Task task) {
        return TaskResponse.builder()
            .id(task.getId())
            .title(task.getTitle())
            .description(task.getDescription())
            .status(task.getStatus())
            .priority(task.getPriority())
            .deadline(task.getDeadline())
            .assigneeId(task.getAssignee() != null ? task.getAssignee().getId() : null)
            .projectId(task.getProject().getId())
            .createdAt(task.getCreatedAt())
            .updatedAt(task.getUpdatedAt())
            .build();
    }
}
