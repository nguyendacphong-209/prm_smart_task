package com.example.prm_smart_task.dto.workspace;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateWorkspaceRequest(
        @NotBlank(message = "Workspace name is required")
        @Size(max = 255, message = "Workspace name must be at most 255 characters")
        String name
) {
}
