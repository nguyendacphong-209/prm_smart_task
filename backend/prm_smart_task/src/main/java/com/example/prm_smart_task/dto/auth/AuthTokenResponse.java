package com.example.prm_smart_task.dto.auth;

import java.time.LocalDateTime;
import java.util.UUID;

public record AuthTokenResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long accessTokenExpiresInMs,
        long refreshTokenExpiresInMs,
        UUID userId,
        String email,
        String fullName,
        String avatarUrl,
        LocalDateTime createdAt
) {
}
