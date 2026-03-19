package com.example.prm_smart_task.dto.workspace;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record InviteWorkspaceMemberRequest(
        @NotBlank(message = "Member email is required")
        @Email(message = "Email is invalid")
        @Size(max = 255, message = "Email must be at most 255 characters")
        String email,

        @Size(max = 50, message = "Role must be at most 50 characters")
        String role
) {
}
