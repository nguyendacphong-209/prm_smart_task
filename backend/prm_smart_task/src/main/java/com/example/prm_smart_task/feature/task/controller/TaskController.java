package com.example.prm_smart_task.feature.task.controller;

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
import com.example.prm_smart_task.dto.task.CreateTaskRequest;
import com.example.prm_smart_task.dto.task.TaskResponse;
import com.example.prm_smart_task.dto.task.UpdateTaskRequest;
import com.example.prm_smart_task.feature.task.service.TaskService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @PostMapping("/projects/{projectId}/tasks")
    public ResponseEntity<TaskResponse> createTask(
            Authentication authentication,
            @PathVariable UUID projectId,
            @Valid @RequestBody CreateTaskRequest request) {
        TaskResponse response = taskService.createTask(authentication.getName(), projectId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/projects/{projectId}/tasks")
    public ResponseEntity<List<TaskResponse>> getTasksByProject(
            Authentication authentication,
            @PathVariable UUID projectId) {
        List<TaskResponse> response = taskService.getTasksByProject(authentication.getName(), projectId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/tasks/{taskId}")
    public ResponseEntity<TaskResponse> updateTask(
            Authentication authentication,
            @PathVariable UUID taskId,
            @Valid @RequestBody UpdateTaskRequest request) {
        TaskResponse response = taskService.updateTask(authentication.getName(), taskId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/tasks/{taskId}")
    public ResponseEntity<ApiMessageResponse> deleteTask(
            Authentication authentication,
            @PathVariable UUID taskId) {
        ApiMessageResponse response = taskService.deleteTask(authentication.getName(), taskId);
        return ResponseEntity.ok(response);
    }
}
