package com.example.prm_smart_task.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.prm_smart_task.dto.collaboration.AttachmentResponse;
import com.example.prm_smart_task.dto.collaboration.CommentResponse;
import com.example.prm_smart_task.dto.collaboration.CreateCommentRequest;
import com.example.prm_smart_task.service.CollaborationService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/tasks/{taskId}")
public class CollaborationController {

    private final CollaborationService collaborationService;

    public CollaborationController(CollaborationService collaborationService) {
        this.collaborationService = collaborationService;
    }

    @PostMapping("/comments")
    public ResponseEntity<CommentResponse> addComment(
            Authentication authentication,
            @PathVariable UUID taskId,
            @Valid @RequestBody CreateCommentRequest request) {
        CommentResponse response = collaborationService.addComment(authentication.getName(), taskId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/comments")
    public ResponseEntity<List<CommentResponse>> getComments(
            Authentication authentication,
            @PathVariable UUID taskId) {
        List<CommentResponse> response = collaborationService.getCommentsByTask(authentication.getName(), taskId);
        return ResponseEntity.ok(response);
    }

    @PostMapping(value = "/attachments/mock-upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<AttachmentResponse> uploadAttachmentMock(
            Authentication authentication,
            @PathVariable UUID taskId,
            @RequestParam("file") MultipartFile file) {
        AttachmentResponse response = collaborationService.uploadAttachmentMock(authentication.getName(), taskId, file);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/attachments")
    public ResponseEntity<List<AttachmentResponse>> getAttachments(
            Authentication authentication,
            @PathVariable UUID taskId) {
        List<AttachmentResponse> response = collaborationService.getAttachmentsByTask(authentication.getName(), taskId);
        return ResponseEntity.ok(response);
    }
}
