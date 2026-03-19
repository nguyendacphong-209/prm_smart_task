package com.example.prm_smart_task.dto.user;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(max = 255, message = "Full name must be at most 255 characters")
        String fullName,

        @Size(max = 1000, message = "Avatar URL is too long")
        String avatarUrl
) {
}
