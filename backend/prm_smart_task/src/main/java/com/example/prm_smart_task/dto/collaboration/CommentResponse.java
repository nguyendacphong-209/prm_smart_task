package com.example.prm_smart_task.dto.collaboration;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record CommentResponse(
        UUID id,
        UUID taskId,
        UUID userId,
        String userEmail,
        String userFullName,
        String userAvatarUrl,
        String content,
        List<String> mentionedEmails,
        LocalDateTime createdAt
) {
}
