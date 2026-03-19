package com.example.prm_smart_task.dto.project;

import jakarta.validation.constraints.Size;

public record UpdateProjectRequest(
        @Size(max = 255, message = "Project name must be at most 255 characters")
        String name,

        @Size(max = 3000, message = "Description is too long")
        String description
) {
}
