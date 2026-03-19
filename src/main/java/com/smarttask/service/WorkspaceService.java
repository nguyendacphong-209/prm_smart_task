package com.smarttask.service;

import com.smarttask.dto.request.WorkspaceRequest;
import com.smarttask.dto.response.WorkspaceResponse;
import java.util.List;
import java.util.UUID;

public interface WorkspaceService {
    WorkspaceResponse createWorkspace(WorkspaceRequest request, UUID userId);
    WorkspaceResponse getWorkspace(UUID id, UUID userId);
    List<WorkspaceResponse> getUserWorkspaces(UUID userId);
    WorkspaceResponse updateWorkspace(UUID id, WorkspaceRequest request, UUID userId);
    void deleteWorkspace(UUID id, UUID userId);
    void addMember(UUID workspaceId, UUID memberId, UUID userId);
    void removeMember(UUID workspaceId, UUID memberId, UUID userId);
}
