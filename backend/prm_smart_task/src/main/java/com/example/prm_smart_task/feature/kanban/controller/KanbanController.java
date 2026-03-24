package com.example.prm_smart_task.feature.kanban.controller;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.kanban.CreateTaskStatusRequest;
import com.example.prm_smart_task.dto.kanban.KanbanBoardResponse;
import com.example.prm_smart_task.dto.kanban.KanbanStatusColumnResponse;
import com.example.prm_smart_task.dto.kanban.KanbanTaskCardResponse;
import com.example.prm_smart_task.dto.kanban.MoveTaskStatusRequest;
import com.example.prm_smart_task.feature.kanban.service.KanbanService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class KanbanController {

    private final KanbanService kanbanService;

    public KanbanController(KanbanService kanbanService) {
        this.kanbanService = kanbanService;
    }

    @GetMapping("/projects/{projectId}/kanban")
    public ResponseEntity<KanbanBoardResponse> getBoard(
            Authentication authentication,
            @PathVariable UUID projectId) {
        KanbanBoardResponse response = kanbanService.getBoard(authentication.getName(), projectId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/projects/{projectId}/statuses")
    public ResponseEntity<KanbanStatusColumnResponse> createStatus(
            Authentication authentication,
            @PathVariable UUID projectId,
            @Valid @RequestBody CreateTaskStatusRequest request) {
        KanbanStatusColumnResponse response = kanbanService.createStatus(authentication.getName(), projectId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/tasks/{taskId}/status")
    public ResponseEntity<KanbanTaskCardResponse> moveTaskToStatus(
            Authentication authentication,
            @PathVariable UUID taskId,
            @Valid @RequestBody MoveTaskStatusRequest request) {
        KanbanTaskCardResponse response = kanbanService.moveTaskToStatus(authentication.getName(), taskId, request);
        return ResponseEntity.ok(response);
    }
}
