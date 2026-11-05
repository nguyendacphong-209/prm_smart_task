package com.example.prm_smart_task.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        @NotBlank(message = "Email is required")
        @Email(message = "Email is invalid")
        @Size(max = 255, message = "Email must be at most 255 characters")
        String email,

        @NotBlank(message = "Reset code is required")
        @Size(max = 100, message = "Reset code is invalid")
        String token,

        @NotBlank(message = "New password is required")
        @Size(min = 6, max = 100, message = "New password must be between 6 and 100 characters")
        String newPassword,

        @NotBlank(message = "Confirm new password is required")
        @Size(min = 6, max = 100, message = "Confirm new password must be between 6 and 100 characters")
        String confirmNewPassword) {
}
