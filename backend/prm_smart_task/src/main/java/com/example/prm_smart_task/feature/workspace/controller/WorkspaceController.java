package com.example.prm_smart_task.feature.workspace.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.workspace.CreateWorkspaceRequest;
import com.example.prm_smart_task.dto.workspace.InviteWorkspaceMemberRequest;
import com.example.prm_smart_task.dto.workspace.UpdateWorkspaceMemberRoleRequest;
import com.example.prm_smart_task.dto.workspace.UpdateWorkspaceRequest;
import com.example.prm_smart_task.dto.workspace.WorkspaceAssigneeOptionResponse;
import com.example.prm_smart_task.dto.workspace.WorkspaceMemberResponse;
import com.example.prm_smart_task.dto.workspace.WorkspaceResponse;
import com.example.prm_smart_task.feature.workspace.service.WorkspaceService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/workspaces")
public class WorkspaceController {

    private final WorkspaceService workspaceService;

    public WorkspaceController(WorkspaceService workspaceService) {
        this.workspaceService = workspaceService;
    }

    @PostMapping
    public ResponseEntity<WorkspaceResponse> createWorkspace(
            Authentication authentication,
            @Valid @RequestBody CreateWorkspaceRequest request) {
        WorkspaceResponse response = workspaceService.createWorkspace(authentication.getName(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/my")
    public ResponseEntity<List<WorkspaceResponse>> getMyWorkspaces(Authentication authentication) {
        List<WorkspaceResponse> response = workspaceService.getMyWorkspaces(authentication.getName());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{workspaceId}")
    public ResponseEntity<WorkspaceResponse> getWorkspaceDetail(
            Authentication authentication,
            @PathVariable UUID workspaceId) {
        WorkspaceResponse response = workspaceService.getWorkspaceDetail(authentication.getName(), workspaceId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{workspaceId}")
    public ResponseEntity<WorkspaceResponse> updateWorkspace(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @Valid @RequestBody UpdateWorkspaceRequest request) {
        WorkspaceResponse response = workspaceService.updateWorkspace(authentication.getName(), workspaceId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{workspaceId}")
    public ResponseEntity<ApiMessageResponse> deleteWorkspace(
            Authentication authentication,
            @PathVariable UUID workspaceId) {
        ApiMessageResponse response = workspaceService.deleteWorkspace(authentication.getName(), workspaceId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{workspaceId}/members/invite")
    public ResponseEntity<WorkspaceMemberResponse> inviteWorkspaceMember(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @Valid @RequestBody InviteWorkspaceMemberRequest request) {
        WorkspaceMemberResponse response = workspaceService.inviteMember(authentication.getName(), workspaceId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{workspaceId}/members")
    public ResponseEntity<List<WorkspaceMemberResponse>> getWorkspaceMembers(
            Authentication authentication,
            @PathVariable UUID workspaceId) {
        List<WorkspaceMemberResponse> response = workspaceService.getWorkspaceMembers(authentication.getName(), workspaceId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{workspaceId}/assignees")
    public ResponseEntity<List<WorkspaceAssigneeOptionResponse>> getWorkspaceAssignees(
            Authentication authentication,
            @PathVariable UUID workspaceId) {
        List<WorkspaceAssigneeOptionResponse> response = workspaceService.getWorkspaceAssignees(authentication.getName(), workspaceId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{workspaceId}/members/{userId}/role")
    public ResponseEntity<WorkspaceMemberResponse> updateWorkspaceMemberRole(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @PathVariable UUID userId,
            @Valid @RequestBody UpdateWorkspaceMemberRoleRequest request) {
        WorkspaceMemberResponse response = workspaceService.updateMemberRole(
                authentication.getName(),
                workspaceId,
                userId,
                request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{workspaceId}/members/{userId}/approve")
    public ResponseEntity<WorkspaceMemberResponse> approveWorkspaceMemberInvitation(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @PathVariable UUID userId) {
        WorkspaceMemberResponse response = workspaceService.approvePendingInvitation(
                authentication.getName(),
                workspaceId,
                userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{workspaceId}/members/{userId}/reject")
    public ResponseEntity<ApiMessageResponse> rejectWorkspaceMemberInvitation(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @PathVariable UUID userId) {
        ApiMessageResponse response = workspaceService.rejectPendingInvitation(
                authentication.getName(),
                workspaceId,
                userId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{workspaceId}/members/{userId}")
    public ResponseEntity<ApiMessageResponse> removeWorkspaceMember(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @PathVariable UUID userId) {
        ApiMessageResponse response = workspaceService.removeMember(authentication.getName(), workspaceId, userId);
        return ResponseEntity.ok(response);
    }
}
