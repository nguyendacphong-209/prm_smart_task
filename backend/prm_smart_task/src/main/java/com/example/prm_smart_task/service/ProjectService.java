package com.example.prm_smart_task.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.project.CreateProjectRequest;
import com.example.prm_smart_task.dto.project.ProjectResponse;
import com.example.prm_smart_task.dto.project.UpdateProjectRequest;
import com.example.prm_smart_task.dto.task.TaskLabelResponse;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.entity.Project;
import com.example.prm_smart_task.entity.TaskStatus;
import com.example.prm_smart_task.entity.Workspace;
import com.example.prm_smart_task.entity.WorkspaceMember;
import com.example.prm_smart_task.exception.BadRequestException;
import com.example.prm_smart_task.exception.UnauthorizedException;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.repository.LabelRepository;
import com.example.prm_smart_task.repository.ProjectRepository;
import com.example.prm_smart_task.repository.TaskStatusRepository;
import com.example.prm_smart_task.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.repository.WorkspaceRepository;

@Service
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final AppUserRepository appUserRepository;
    private final TaskStatusRepository taskStatusRepository;
    private final LabelRepository labelRepository;

    public ProjectService(
            ProjectRepository projectRepository,
            WorkspaceRepository workspaceRepository,
            WorkspaceMemberRepository workspaceMemberRepository,
            AppUserRepository appUserRepository,
            TaskStatusRepository taskStatusRepository,
            LabelRepository labelRepository) {
        this.projectRepository = projectRepository;
        this.workspaceRepository = workspaceRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.appUserRepository = appUserRepository;
        this.taskStatusRepository = taskStatusRepository;
        this.labelRepository = labelRepository;
    }

    @Transactional
    public ProjectResponse createProject(String currentEmail, UUID workspaceId, CreateProjectRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = workspaceRepository.findById(workspaceId)
                .orElseThrow(() -> new BadRequestException("Workspace not found"));

        ensureCanManageProject(currentUser, workspace);

        Project project = new Project();
        project.setWorkspace(workspace);
        project.setName(request.name().trim());
        project.setDescription(normalizeNullableText(request.description()));

        Project savedProject = projectRepository.save(project);
        seedDefaultStatuses(savedProject);
        return mapProject(savedProject);
    }

    @Transactional(readOnly = true)
    public List<ProjectResponse> getProjectsByWorkspace(String currentEmail, UUID workspaceId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = workspaceRepository.findById(workspaceId)
                .orElseThrow(() -> new BadRequestException("Workspace not found"));

        ensureWorkspaceMember(currentUser, workspace.getId());

        return projectRepository.findByWorkspaceId(workspaceId)
                .stream()
                .map(this::mapProject)
                .toList();
    }

    @Transactional
    public ProjectResponse updateProject(String currentEmail, UUID projectId, UpdateProjectRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BadRequestException("Project not found"));

        ensureCanManageProject(currentUser, project.getWorkspace());

        if (request.name() != null) {
            String normalizedName = request.name().trim();
            if (normalizedName.isBlank()) {
                throw new BadRequestException("Project name must not be blank");
            }
            project.setName(normalizedName);
        }

        if (request.description() != null) {
            project.setDescription(normalizeNullableText(request.description()));
        }

        Project updatedProject = projectRepository.save(project);
        return mapProject(updatedProject);
    }

    @Transactional
    public ApiMessageResponse deleteProject(String currentEmail, UUID projectId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BadRequestException("Project not found"));

        ensureCanManageProject(currentUser, project.getWorkspace());
        projectRepository.delete(project);

        return new ApiMessageResponse("Project deleted successfully");
    }

    @Transactional(readOnly = true)
    public List<TaskLabelResponse> getLabelsByProject(String currentEmail, UUID projectId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BadRequestException("Project not found"));

        ensureWorkspaceMember(currentUser, project.getWorkspace().getId());

        return labelRepository.findByProjectId(projectId)
                .stream()
                .map(label -> new TaskLabelResponse(label.getId(), label.getName(), label.getColor()))
                .toList();
    }

    private AppUser getUserByEmail(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        return appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private void ensureWorkspaceMember(AppUser currentUser, UUID workspaceId) {
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }
    }

    private void ensureCanManageProject(AppUser currentUser, Workspace workspace) {
        if (workspace.getOwner().getId().equals(currentUser.getId())) {
            return;
        }

        WorkspaceMember member = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspace.getId(), currentUser.getId())
                .orElseThrow(() -> new UnauthorizedException("You are not a member of this workspace"));

        if (!"admin".equalsIgnoreCase(member.getRole())) {
            throw new UnauthorizedException("Only workspace owner or admin can manage projects");
        }
    }

    private String normalizeNullableText(String value) {
        if (value == null) {
            return null;
        }
        String normalizedValue = value.trim();
        return normalizedValue.isBlank() ? null : normalizedValue;
    }

    private ProjectResponse mapProject(Project project) {
        return new ProjectResponse(
                project.getId(),
                project.getWorkspace().getId(),
                project.getName(),
                project.getDescription(),
                project.getCreatedAt());
    }

    private void seedDefaultStatuses(Project project) {
        TaskStatus toDo = new TaskStatus();
        toDo.setProject(project);
        toDo.setName("To Do");
        toDo.setPosition(1);
        taskStatusRepository.save(toDo);
    }
}
