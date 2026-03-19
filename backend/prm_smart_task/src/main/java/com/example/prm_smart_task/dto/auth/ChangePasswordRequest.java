package com.example.prm_smart_task.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(
        @NotBlank(message = "Current password is required")
        @Size(min = 6, max = 100, message = "Current password must be between 6 and 100 characters")
        String currentPassword,

        @NotBlank(message = "New password is required")
        @Size(min = 6, max = 100, message = "New password must be between 6 and 100 characters")
        String newPassword,

        @NotBlank(message = "Confirm new password is required")
        @Size(min = 6, max = 100, message = "Confirm new password must be between 6 and 100 characters")
        String confirmNewPassword
) {
}
