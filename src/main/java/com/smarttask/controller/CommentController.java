package com.smarttask.controller;

import com.smarttask.dto.request.CommentRequest;
import com.smarttask.dto.response.CommentResponse;
import com.smarttask.entity.User;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.CommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;
    private final UserRepository userRepository;

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getId();
    }

    @PostMapping
    public ResponseEntity<CommentResponse> add(@Valid @RequestBody CommentRequest request,
                                                @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(commentService.addComment(request, getUserId(userDetails)));
    }

    @GetMapping("/task/{taskId}")
    public ResponseEntity<List<CommentResponse>> getTaskComments(@PathVariable UUID taskId) {
        return ResponseEntity.ok(commentService.getTaskComments(taskId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CommentResponse> update(@PathVariable UUID id,
                                                   @RequestBody Map<String, String> body,
                                                   @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(commentService.updateComment(id, body.get("content"), getUserId(userDetails)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id,
                                        @AuthenticationPrincipal UserDetails userDetails) {
        commentService.deleteComment(id, getUserId(userDetails));
        return ResponseEntity.noContent().build();
    }
}
