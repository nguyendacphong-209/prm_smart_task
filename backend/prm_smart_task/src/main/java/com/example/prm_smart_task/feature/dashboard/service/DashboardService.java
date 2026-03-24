package com.example.prm_smart_task.feature.dashboard.service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.dashboard.ProjectDashboardResponse;
import com.example.prm_smart_task.dto.dashboard.UserDashboardResponse;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.project.entity.Project;
import com.example.prm_smart_task.feature.task.entity.Task;
import com.example.prm_smart_task.feature.task.entity.TaskAssignment;
import com.example.prm_smart_task.feature.task.entity.TaskStatus;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.project.repository.ProjectRepository;
import com.example.prm_smart_task.feature.task.repository.TaskAssignmentRepository;
import com.example.prm_smart_task.feature.task.repository.TaskRepository;
import com.example.prm_smart_task.feature.task.repository.TaskStatusRepository;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;

@Service
public class DashboardService {

    private final ProjectRepository projectRepository;
    private final TaskRepository taskRepository;
    private final TaskStatusRepository taskStatusRepository;
    private final TaskAssignmentRepository taskAssignmentRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final AppUserRepository appUserRepository;

    public DashboardService(
            ProjectRepository projectRepository,
            TaskRepository taskRepository,
            TaskStatusRepository taskStatusRepository,
            TaskAssignmentRepository taskAssignmentRepository,
            WorkspaceMemberRepository workspaceMemberRepository,
            AppUserRepository appUserRepository) {
        this.projectRepository = projectRepository;
        this.taskRepository = taskRepository;
        this.taskStatusRepository = taskStatusRepository;
        this.taskAssignmentRepository = taskAssignmentRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.appUserRepository = appUserRepository;
    }

    @Transactional(readOnly = true)
    public ProjectDashboardResponse getProjectDashboard(String currentEmail, UUID projectId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = getProject(projectId);
        ensureWorkspaceMember(currentUser, project.getWorkspace().getId());

        List<Task> tasks = taskRepository.findByProjectId(projectId);
        List<TaskStatus> statuses = taskStatusRepository.findByProjectIdOrderByPositionAsc(projectId);

        int maxPosition = statuses.stream()
                .mapToInt(TaskStatus::getPosition)
                .max()
                .orElse(0);

        long completedCount = tasks.stream()
                .filter(task -> task.getStatus() != null && task.getStatus().getPosition() == maxPosition)
                .count();

        long totalCount = tasks.size();
        double completionPercentage = totalCount == 0 ? 0.0 : (completedCount * 100.0) / totalCount;

        Map<String, Long> tasksByStatus = tasks.stream()
                .collect(Collectors.groupingBy(
                        task -> task.getStatus() == null ? "No Status" : task.getStatus().getName(),
                        Collectors.counting()));

        Map<String, Long> tasksByPriority = tasks.stream()
                .collect(Collectors.groupingBy(
                        task -> task.getPriority() == null ? "No Priority" : task.getPriority(),
                        Collectors.counting()));

        return new ProjectDashboardResponse(
                project.getId(),
                project.getName(),
                completionPercentage,
                totalCount,
                completedCount,
                tasksByStatus,
                tasksByPriority);
    }

    @Transactional(readOnly = true)
    public UserDashboardResponse getUserDashboard(String currentEmail) {
        AppUser currentUser = getUserByEmail(currentEmail);

        List<TaskAssignment> assignments = taskAssignmentRepository.findByUserId(currentUser.getId());
        List<Task> assignedTasks = assignments.stream()
                .map(TaskAssignment::getTask)
                .collect(Collectors.toList());

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime sevenDaysLater = now.plusDays(7);

        long completedCount = assignedTasks.stream()
                .filter(task -> task.getStatus() != null && isTaskCompleted(task))
                .count();

        long overdueCount = assignedTasks.stream()
                .filter(task -> task.getDeadline() != null && task.getDeadline().isBefore(now) && !isTaskCompleted(task))
                .count();

        long dueSoonCount = assignedTasks.stream()
                .filter(task -> task.getDeadline() != null
                        && task.getDeadline().isAfter(now)
                        && task.getDeadline().isBefore(sevenDaysLater)
                        && !isTaskCompleted(task))
                .count();

        Map<String, Long> tasksByPriority = assignedTasks.stream()
                .collect(Collectors.groupingBy(
                        task -> task.getPriority() == null ? "No Priority" : task.getPriority(),
                        Collectors.counting()));

        Map<String, Long> tasksByStatus = assignedTasks.stream()
                .collect(Collectors.groupingBy(
                        task -> task.getStatus() == null ? "No Status" : task.getStatus().getName(),
                        Collectors.counting()));

        return new UserDashboardResponse(
                assignedTasks.size(),
                completedCount,
                overdueCount,
                dueSoonCount,
                tasksByPriority,
                tasksByStatus);
    }

    private boolean isTaskCompleted(Task task) {
        if (task.getStatus() == null) {
            return false;
        }

        Project project = task.getProject();
        if (project == null) {
            return false;
        }

        List<TaskStatus> statuses = taskStatusRepository.findByProjectIdOrderByPositionAsc(project.getId());
        int maxPosition = statuses.stream()
                .mapToInt(TaskStatus::getPosition)
                .max()
                .orElse(0);

        return task.getStatus().getPosition() == maxPosition;
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
}
