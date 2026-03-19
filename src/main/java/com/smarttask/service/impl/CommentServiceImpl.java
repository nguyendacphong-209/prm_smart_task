package com.smarttask.service.impl;

import com.smarttask.dto.request.CommentRequest;
import com.smarttask.dto.response.CommentResponse;
import com.smarttask.entity.Comment;
import com.smarttask.entity.Task;
import com.smarttask.entity.User;
import com.smarttask.enums.NotificationType;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.exception.UnauthorizedException;
import com.smarttask.repository.CommentRepository;
import com.smarttask.repository.TaskRepository;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.CommentService;
import com.smarttask.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl implements CommentService {

    private final CommentRepository commentRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public CommentResponse addComment(CommentRequest request, UUID userId) {
        Task task = taskRepository.findById(request.getTaskId())
            .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        User author = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Comment comment = Comment.builder()
            .content(request.getContent())
            .author(author)
            .task(task)
            .build();
        comment = commentRepository.save(comment);
        if (task.getAssignee() != null && !task.getAssignee().getId().equals(userId)) {
            notificationService.createNotification(
                NotificationType.COMMENT_ADDED,
                "New comment on task: " + task.getTitle(),
                task.getAssignee().getId(),
                task.getId()
            );
        }
        return toResponse(comment);
    }

    @Override
    public List<CommentResponse> getTaskComments(UUID taskId) {
        return commentRepository.findByTaskId(taskId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public CommentResponse updateComment(UUID id, String content, UUID userId) {
        Comment comment = commentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        if (!comment.getAuthor().getId().equals(userId)) {
            throw new UnauthorizedException("You can only edit your own comments");
        }
        comment.setContent(content);
        return toResponse(commentRepository.save(comment));
    }

    @Override
    @Transactional
    public void deleteComment(UUID id, UUID userId) {
        Comment comment = commentRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        if (!comment.getAuthor().getId().equals(userId)) {
            throw new UnauthorizedException("You can only delete your own comments");
        }
        commentRepository.delete(comment);
    }

    private CommentResponse toResponse(Comment comment) {
        return CommentResponse.builder()
            .id(comment.getId())
            .content(comment.getContent())
            .authorId(comment.getAuthor().getId())
            .taskId(comment.getTask().getId())
            .createdAt(comment.getCreatedAt())
            .build();
    }
}
