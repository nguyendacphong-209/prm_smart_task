package com.smarttask.controller;

import com.smarttask.dto.request.WorkspaceRequest;
import com.smarttask.dto.response.WorkspaceResponse;
import com.smarttask.entity.User;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.WorkspaceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/workspaces")
@RequiredArgsConstructor
public class WorkspaceController {

    private final WorkspaceService workspaceService;
    private final UserRepository userRepository;

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getId();
    }

    @PostMapping
    public ResponseEntity<WorkspaceResponse> create(@Valid @RequestBody WorkspaceRequest request,
                                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(workspaceService.createWorkspace(request, getUserId(userDetails)));
    }

    @GetMapping
    public ResponseEntity<List<WorkspaceResponse>> getUserWorkspaces(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(workspaceService.getUserWorkspaces(getUserId(userDetails)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<WorkspaceResponse> getWorkspace(@PathVariable UUID id,
                                                           @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(workspaceService.getWorkspace(id, getUserId(userDetails)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<WorkspaceResponse> update(@PathVariable UUID id,
                                                     @Valid @RequestBody WorkspaceRequest request,
                                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(workspaceService.updateWorkspace(id, request, getUserId(userDetails)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                        @AuthenticationPrincipal UserDetails userDetails) {
        workspaceService.deleteWorkspace(id, getUserId(userDetails));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/members/{memberId}")
    public ResponseEntity<Void> addMember(@PathVariable UUID id,
                                           @PathVariable UUID memberId,
                                           @AuthenticationPrincipal UserDetails userDetails) {
        workspaceService.addMember(id, memberId, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}/members/{memberId}")
    public ResponseEntity<Void> removeMember(@PathVariable UUID id,
                                              @PathVariable UUID memberId,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        workspaceService.removeMember(id, memberId, getUserId(userDetails));
        return ResponseEntity.noContent().build();
    }
}
