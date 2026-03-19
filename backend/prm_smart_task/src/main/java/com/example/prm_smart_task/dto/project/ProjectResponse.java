package com.example.prm_smart_task.dto.project;

import java.time.LocalDateTime;
import java.util.UUID;

public record ProjectResponse(
        UUID id,
        UUID workspaceId,
        String name,
        String description,
        LocalDateTime createdAt
) {
}
