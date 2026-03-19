package com.example.prm_smart_task.controller;

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
import com.example.prm_smart_task.dto.project.CreateProjectRequest;
import com.example.prm_smart_task.dto.project.ProjectResponse;
import com.example.prm_smart_task.dto.project.UpdateProjectRequest;
import com.example.prm_smart_task.dto.task.TaskLabelResponse;
import com.example.prm_smart_task.service.ProjectService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @PostMapping("/workspaces/{workspaceId}/projects")
    public ResponseEntity<ProjectResponse> createProject(
            Authentication authentication,
            @PathVariable UUID workspaceId,
            @Valid @RequestBody CreateProjectRequest request) {
        ProjectResponse response = projectService.createProject(authentication.getName(), workspaceId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/workspaces/{workspaceId}/projects")
    public ResponseEntity<List<ProjectResponse>> getProjectsByWorkspace(
            Authentication authentication,
            @PathVariable UUID workspaceId) {
        List<ProjectResponse> response = projectService.getProjectsByWorkspace(authentication.getName(), workspaceId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/projects/{projectId}")
    public ResponseEntity<ProjectResponse> updateProject(
            Authentication authentication,
            @PathVariable UUID projectId,
            @Valid @RequestBody UpdateProjectRequest request) {
        ProjectResponse response = projectService.updateProject(authentication.getName(), projectId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/projects/{projectId}/labels")
    public ResponseEntity<List<TaskLabelResponse>> getLabelsByProject(
            Authentication authentication,
            @PathVariable UUID projectId) {
        List<TaskLabelResponse> response = projectService.getLabelsByProject(authentication.getName(), projectId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/projects/{projectId}")
    public ResponseEntity<ApiMessageResponse> deleteProject(
            Authentication authentication,
            @PathVariable UUID projectId) {
        ApiMessageResponse response = projectService.deleteProject(authentication.getName(), projectId);
        return ResponseEntity.ok(response);
    }
}
