package com.example.prm_smart_task.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "Email is required")
        @Email(message = "Email is invalid")
        @Size(max = 255, message = "Email must be at most 255 characters")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 6, max = 100, message = "Password must be between 6 and 100 characters")
        String password,

        @Size(max = 255, message = "Full name must be at most 255 characters")
        String fullName,

        @Size(max = 1000, message = "Avatar URL is too long")
        String avatarUrl
) {
}
