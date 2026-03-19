package com.example.prm_smart_task.dto.workspace;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateWorkspaceMemberRoleRequest(
        @NotBlank(message = "Role is required")
        @Size(max = 50, message = "Role must be at most 50 characters")
        String role
) {
}
