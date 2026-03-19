package com.example.prm_smart_task.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LogoutRequest(
        @NotBlank(message = "Refresh token is required")
        @Size(max = 255, message = "Refresh token is too long")
        String refreshToken
) {
}
