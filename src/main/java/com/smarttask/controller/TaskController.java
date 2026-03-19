package com.smarttask.controller;

import com.smarttask.dto.request.TaskRequest;
import com.smarttask.dto.response.TaskResponse;
import com.smarttask.entity.User;
import com.smarttask.enums.TaskStatus;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.TaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import com.smarttask.dto.request.UpdateTaskStatusRequest;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;
    private final UserRepository userRepository;

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getId();
    }

    @PostMapping
    public ResponseEntity<TaskResponse> create(@Valid @RequestBody TaskRequest request,
                                                @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(taskService.createTask(request, getUserId(userDetails)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaskResponse> getTask(@PathVariable UUID id) {
        return ResponseEntity.ok(taskService.getTask(id));
    }

    @GetMapping("/assignee/{assigneeId}")
    public ResponseEntity<List<TaskResponse>> getByAssignee(@PathVariable UUID assigneeId) {
        return ResponseEntity.ok(taskService.getAssigneeTasks(assigneeId));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<TaskResponse>> getProjectTasks(@PathVariable UUID projectId) {
        return ResponseEntity.ok(taskService.getProjectTasks(projectId));
    }

    @GetMapping("/project/{projectId}/status/{status}")
    public ResponseEntity<List<TaskResponse>> getByStatus(@PathVariable UUID projectId,
                                                           @PathVariable TaskStatus status) {
        return ResponseEntity.ok(taskService.getProjectTasksByStatus(projectId, status));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaskResponse> update(@PathVariable UUID id,
                                                @Valid @RequestBody TaskRequest request) {
        return ResponseEntity.ok(taskService.updateTask(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/assign/{assigneeId}")
    public ResponseEntity<Void> assign(@PathVariable UUID id,
                                        @PathVariable UUID assigneeId,
                                        @AuthenticationPrincipal UserDetails userDetails) {
        taskService.assignTask(id, assigneeId, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskResponse> updateStatus(@PathVariable UUID id,
                                                      @Valid @RequestBody UpdateTaskStatusRequest body,
                                                      @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(taskService.updateTaskStatus(id, body.getStatus(), getUserId(userDetails)));
    }
}
