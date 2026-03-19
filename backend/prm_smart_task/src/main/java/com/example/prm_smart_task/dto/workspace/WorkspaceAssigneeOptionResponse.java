package com.example.prm_smart_task.dto.workspace;

import java.util.UUID;

public record WorkspaceAssigneeOptionResponse(
        UUID userId,
        String email,
        String fullName,
        String avatarUrl
) {
}
