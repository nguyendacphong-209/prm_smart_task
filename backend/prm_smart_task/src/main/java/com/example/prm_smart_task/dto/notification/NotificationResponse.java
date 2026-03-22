package com.example.prm_smart_task.dto.notification;

import java.time.LocalDateTime;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        String type,
        String content,
        boolean isRead,
        UUID workspaceId,
        UUID targetUserId,
        LocalDateTime createdAt
) {
}
