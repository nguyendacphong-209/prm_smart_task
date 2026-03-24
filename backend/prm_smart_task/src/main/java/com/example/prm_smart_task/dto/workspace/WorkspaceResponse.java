package com.example.prm_smart_task.dto.workspace;

import java.time.LocalDateTime;
import java.util.UUID;

public record WorkspaceResponse(
        UUID id,
        String name,
        UUID ownerId,
        String ownerEmail,
        String myRole,
        String imageUrl,
        LocalDateTime createdAt
) {
}
