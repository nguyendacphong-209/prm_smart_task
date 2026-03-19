package com.example.prm_smart_task.dto.user;

import java.time.LocalDateTime;
import java.util.UUID;

public record CurrentUserResponse(
        UUID id,
        String email,
        String fullName,
        String avatarUrl,
        LocalDateTime createdAt
) {
}
