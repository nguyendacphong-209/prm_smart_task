package com.smarttask.service;

import com.smarttask.dto.request.ProjectRequest;
import com.smarttask.dto.response.ProjectResponse;
import java.util.List;
import java.util.UUID;

public interface ProjectService {
    ProjectResponse createProject(ProjectRequest request, UUID userId);
    ProjectResponse getProject(UUID id);
    List<ProjectResponse> getWorkspaceProjects(UUID workspaceId);
    ProjectResponse updateProject(UUID id, ProjectRequest request);
    void deleteProject(UUID id);
}
