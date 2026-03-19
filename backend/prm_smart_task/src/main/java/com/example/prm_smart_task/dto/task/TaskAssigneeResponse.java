package com.example.prm_smart_task.dto.task;

import java.util.UUID;

public record TaskAssigneeResponse(
        UUID userId,
        String email,
        String fullName,
        String avatarUrl
) {
}
