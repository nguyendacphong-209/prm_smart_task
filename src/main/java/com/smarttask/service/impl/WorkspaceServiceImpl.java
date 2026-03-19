package com.smarttask.service.impl;

import com.smarttask.dto.request.WorkspaceRequest;
import com.smarttask.dto.response.WorkspaceResponse;
import com.smarttask.entity.User;
import com.smarttask.entity.Workspace;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.exception.UnauthorizedException;
import com.smarttask.repository.UserRepository;
import com.smarttask.repository.WorkspaceRepository;
import com.smarttask.service.WorkspaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class WorkspaceServiceImpl implements WorkspaceService {

    private final WorkspaceRepository workspaceRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public WorkspaceResponse createWorkspace(WorkspaceRequest request, UUID userId) {
        User owner = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Workspace workspace = Workspace.builder()
            .name(request.getName())
            .description(request.getDescription())
            .owner(owner)
            .build();
        workspace.getMembers().add(owner);
        return toResponse(workspaceRepository.save(workspace));
    }

    @Override
    public WorkspaceResponse getWorkspace(UUID id, UUID userId) {
        Workspace workspace = workspaceRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        boolean isOwner = workspace.getOwner().getId().equals(userId);
        boolean isMember = workspace.getMembers().stream().anyMatch(m -> m.getId().equals(userId));
        if (!isOwner && !isMember) {
            throw new UnauthorizedException("You do not have access to this workspace");
        }
        return toResponse(workspace);
    }

    @Override
    public List<WorkspaceResponse> getUserWorkspaces(UUID userId) {
        List<Workspace> owned = workspaceRepository.findByOwnerId(userId);
        List<Workspace> member = workspaceRepository.findByMembersId(userId);
        return Stream.concat(owned.stream(), member.stream())
            .distinct()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public WorkspaceResponse updateWorkspace(UUID id, WorkspaceRequest request, UUID userId) {
        Workspace workspace = workspaceRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        if (!workspace.getOwner().getId().equals(userId)) {
            throw new UnauthorizedException("Only the owner can update the workspace");
        }
        workspace.setName(request.getName());
        workspace.setDescription(request.getDescription());
        return toResponse(workspaceRepository.save(workspace));
    }

    @Override
    @Transactional
    public void deleteWorkspace(UUID id, UUID userId) {
        Workspace workspace = workspaceRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        if (!workspace.getOwner().getId().equals(userId)) {
            throw new UnauthorizedException("Only the owner can delete the workspace");
        }
        workspaceRepository.delete(workspace);
    }

    @Override
    @Transactional
    public void addMember(UUID workspaceId, UUID memberId, UUID userId) {
        Workspace workspace = workspaceRepository.findById(workspaceId)
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        if (!workspace.getOwner().getId().equals(userId)) {
            throw new UnauthorizedException("Only the owner can add members");
        }
        User member = userRepository.findById(memberId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (workspace.getMembers().contains(member)) {
            return; // already a member — idempotent
        }
        workspace.getMembers().add(member);
        workspaceRepository.save(workspace);
    }

    @Override
    @Transactional
    public void removeMember(UUID workspaceId, UUID memberId, UUID userId) {
        Workspace workspace = workspaceRepository.findById(workspaceId)
            .orElseThrow(() -> new ResourceNotFoundException("Workspace not found"));
        if (!workspace.getOwner().getId().equals(userId)) {
            throw new UnauthorizedException("Only the owner can remove members");
        }
        User member = userRepository.findById(memberId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!workspace.getMembers().contains(member)) {
            throw new ResourceNotFoundException("User is not a member of this workspace");
        }
        workspace.getMembers().remove(member);
        workspaceRepository.save(workspace);
    }

    private WorkspaceResponse toResponse(Workspace workspace) {
        return WorkspaceResponse.builder()
            .id(workspace.getId())
            .name(workspace.getName())
            .description(workspace.getDescription())
            .ownerId(workspace.getOwner().getId())
            .createdAt(workspace.getCreatedAt())
            .updatedAt(workspace.getUpdatedAt())
            .build();
    }
}
