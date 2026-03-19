package com.smarttask.service.impl;

import com.smarttask.dto.request.ProjectRequest;
import com.smarttask.dto.response.ProjectResponse;
import com.smarttask.entity.Project;
import com.smarttask.entity.Workspace;
import com.smarttask.enums.ProjectStatus;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.ProjectRepository;
import com.smarttask.repository.WorkspaceRepository;
import com.smarttask.service.ProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final WorkspaceRepository workspaceRepository;

    @Override
    @Transactional
    public ProjectResponse createProject(ProjectRequest request, UUID userId) {
        Workspace workspace = workspaceRepository.findById(request.getWorkspaceId())
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        Project project = Project.builder()
            .name(request.getName())
            .description(request.getDescription())
            .workspace(workspace)
            .status(ProjectStatus.ACTIVE)
            .build();
        return toResponse(projectRepository.save(project));
    }

    @Override
    public ProjectResponse getProject(UUID id) {
        return toResponse(projectRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Project not found")));
    }

    @Override
    public List<ProjectResponse> getWorkspaceProjects(UUID workspaceId) {
        return projectRepository.findByWorkspaceId(workspaceId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ProjectResponse updateProject(UUID id, ProjectRequest request) {
        Project project = projectRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        return toResponse(projectRepository.save(project));
    }

    @Override
    @Transactional
    public void deleteProject(UUID id) {
        Project project = projectRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        projectRepository.delete(project);
    }

    private ProjectResponse toResponse(Project project) {
        return ProjectResponse.builder()
            .id(project.getId())
            .name(project.getName())
            .description(project.getDescription())
            .status(project.getStatus())
            .workspaceId(project.getWorkspace().getId())
            .createdAt(project.getCreatedAt())
            .updatedAt(project.getUpdatedAt())
            .build();
    }
}
