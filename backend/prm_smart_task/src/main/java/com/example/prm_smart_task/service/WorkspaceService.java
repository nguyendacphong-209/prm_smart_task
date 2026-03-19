package com.example.prm_smart_task.service;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.workspace.CreateWorkspaceRequest;
import com.example.prm_smart_task.dto.workspace.InviteWorkspaceMemberRequest;
import com.example.prm_smart_task.dto.workspace.UpdateWorkspaceMemberRoleRequest;
import com.example.prm_smart_task.dto.workspace.UpdateWorkspaceRequest;
import com.example.prm_smart_task.dto.workspace.WorkspaceAssigneeOptionResponse;
import com.example.prm_smart_task.dto.workspace.WorkspaceMemberResponse;
import com.example.prm_smart_task.dto.workspace.WorkspaceResponse;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.entity.Workspace;
import com.example.prm_smart_task.entity.WorkspaceMember;
import com.example.prm_smart_task.exception.BadRequestException;
import com.example.prm_smart_task.exception.UnauthorizedException;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.repository.WorkspaceRepository;

@Service
public class WorkspaceService {

    private final WorkspaceRepository workspaceRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final AppUserRepository appUserRepository;

    public WorkspaceService(
            WorkspaceRepository workspaceRepository,
            WorkspaceMemberRepository workspaceMemberRepository,
            AppUserRepository appUserRepository) {
        this.workspaceRepository = workspaceRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.appUserRepository = appUserRepository;
    }

    @Transactional
    public WorkspaceResponse createWorkspace(String currentEmail, CreateWorkspaceRequest request) {
        AppUser owner = getUserByEmail(currentEmail);

        Workspace workspace = new Workspace();
        workspace.setName(request.name().trim());
        workspace.setOwner(owner);

        Workspace savedWorkspace = workspaceRepository.save(workspace);

        WorkspaceMember ownerMember = new WorkspaceMember();
        ownerMember.setWorkspace(savedWorkspace);
        ownerMember.setUser(owner);
        ownerMember.setRole("owner");
        workspaceMemberRepository.save(ownerMember);

        return mapWorkspace(savedWorkspace, owner.getId());
    }

    @Transactional(readOnly = true)
    public List<WorkspaceResponse> getMyWorkspaces(String currentEmail) {
        AppUser currentUser = getUserByEmail(currentEmail);
        LinkedHashSet<Workspace> workspaces = new LinkedHashSet<>();

        workspaces.addAll(workspaceRepository.findByOwnerId(currentUser.getId()));
        workspaceMemberRepository.findByUserId(currentUser.getId())
            .stream()
            .map(WorkspaceMember::getWorkspace)
            .forEach(workspaces::add);

        return workspaces.stream()
            .map(workspace -> mapWorkspace(workspace, currentUser.getId()))
                .toList();
    }

    @Transactional(readOnly = true)
    public WorkspaceResponse getWorkspaceDetail(String currentEmail, UUID workspaceId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = workspaceRepository.findById(workspaceId)
                .orElseThrow(() -> new BadRequestException("Workspace not found"));

        boolean isOwner = workspace.getOwner().getId().equals(currentUser.getId());
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isOwner && !isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }

        return mapWorkspace(workspace, currentUser.getId());
    }

    @Transactional
    public WorkspaceResponse updateWorkspace(String currentEmail, UUID workspaceId, UpdateWorkspaceRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = getOwnerWorkspace(workspaceId, currentUser.getId());

        workspace.setName(request.name().trim());
        Workspace updatedWorkspace = workspaceRepository.save(workspace);

        return mapWorkspace(updatedWorkspace, currentUser.getId());
    }

    @Transactional
    public ApiMessageResponse deleteWorkspace(String currentEmail, UUID workspaceId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = getOwnerWorkspace(workspaceId, currentUser.getId());

        workspaceRepository.delete(workspace);
        return new ApiMessageResponse("Workspace deleted successfully");
    }

    @Transactional
    public WorkspaceMemberResponse inviteMember(
            String currentEmail,
            UUID workspaceId,
            InviteWorkspaceMemberRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = getOwnerWorkspace(workspaceId, currentUser.getId());

        String invitedEmail = request.email().trim().toLowerCase();
        AppUser invitedUser = appUserRepository.findByEmail(invitedEmail)
                .orElseThrow(() -> new BadRequestException("Invited user does not exist"));

        if (workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, invitedUser.getId())) {
            throw new BadRequestException("User is already a workspace member");
        }

        String role = normalizeMemberRole(request.role());

        WorkspaceMember workspaceMember = new WorkspaceMember();
        workspaceMember.setWorkspace(workspace);
        workspaceMember.setUser(invitedUser);
        workspaceMember.setRole(role);

        WorkspaceMember savedMember = workspaceMemberRepository.save(workspaceMember);
        return mapMember(savedMember);
    }

    @Transactional
    public WorkspaceMemberResponse updateMemberRole(
            String currentEmail,
            UUID workspaceId,
            UUID userId,
            UpdateWorkspaceMemberRoleRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = getOwnerWorkspace(workspaceId, currentUser.getId());

        if (workspace.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Cannot change role of workspace owner");
        }

        WorkspaceMember member = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new BadRequestException("Workspace member not found"));

        member.setRole(normalizeMemberRole(request.role()));
        WorkspaceMember savedMember = workspaceMemberRepository.save(member);
        return mapMember(savedMember);
    }

    @Transactional
    public ApiMessageResponse removeMember(String currentEmail, UUID workspaceId, UUID userId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Workspace workspace = getOwnerWorkspace(workspaceId, currentUser.getId());

        if (workspace.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Cannot remove workspace owner");
        }

        WorkspaceMember member = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspaceId, userId)
                .orElseThrow(() -> new BadRequestException("Workspace member not found"));

        workspaceMemberRepository.delete(member);
        return new ApiMessageResponse("Member removed successfully");
    }

    @Transactional(readOnly = true)
    public List<WorkspaceMemberResponse> getWorkspaceMembers(String currentEmail, UUID workspaceId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }

        return workspaceMemberRepository.findByWorkspaceId(workspaceId)
                .stream()
                .map(this::mapMember)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<WorkspaceAssigneeOptionResponse> getWorkspaceAssignees(String currentEmail, UUID workspaceId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }

        return workspaceMemberRepository.findByWorkspaceId(workspaceId)
                .stream()
                .map(this::mapAssigneeOption)
                .toList();
    }

    private AppUser getUserByEmail(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        return appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private Workspace getOwnerWorkspace(UUID workspaceId, UUID ownerId) {
        return workspaceRepository.findByIdAndOwnerId(workspaceId, ownerId)
                .orElseThrow(() -> new UnauthorizedException("Only workspace owner can perform this action"));
    }

    private String normalizeMemberRole(String role) {
        String normalizedRole = role == null || role.isBlank() ? "member" : role.trim().toLowerCase();
        if (!"member".equals(normalizedRole) && !"admin".equals(normalizedRole)) {
            throw new BadRequestException("Role must be either member or admin");
        }
        return normalizedRole;
    }

    private WorkspaceResponse mapWorkspace(Workspace workspace, UUID currentUserId) {
        String myRole;
        if (workspace.getOwner().getId().equals(currentUserId)) {
            myRole = "owner";
        } else {
            myRole = workspaceMemberRepository.findByWorkspaceIdAndUserId(workspace.getId(), currentUserId)
                    .map(WorkspaceMember::getRole)
                    .orElse("member");
        }

        return new WorkspaceResponse(
                workspace.getId(),
                workspace.getName(),
                workspace.getOwner().getId(),
                workspace.getOwner().getEmail(),
                myRole,
                workspace.getCreatedAt());
    }

    private WorkspaceMemberResponse mapMember(WorkspaceMember member) {
        return new WorkspaceMemberResponse(
                member.getId(),
                member.getWorkspace().getId(),
                member.getUser().getId(),
                member.getUser().getEmail(),
                member.getUser().getFullName(),
                member.getUser().getAvatarUrl(),
                member.getRole());
    }

    private WorkspaceAssigneeOptionResponse mapAssigneeOption(WorkspaceMember member) {
        return new WorkspaceAssigneeOptionResponse(
                member.getUser().getId(),
                member.getUser().getEmail(),
                member.getUser().getFullName(),
                member.getUser().getAvatarUrl());
    }
}
