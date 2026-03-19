package com.smarttask.service;

import com.smarttask.dto.request.CommentRequest;
import com.smarttask.dto.response.CommentResponse;
import java.util.List;
import java.util.UUID;

public interface CommentService {
    CommentResponse addComment(CommentRequest request, UUID userId);
    List<CommentResponse> getTaskComments(UUID taskId);
    CommentResponse updateComment(UUID id, String content, UUID userId);
    void deleteComment(UUID id, UUID userId);
}
