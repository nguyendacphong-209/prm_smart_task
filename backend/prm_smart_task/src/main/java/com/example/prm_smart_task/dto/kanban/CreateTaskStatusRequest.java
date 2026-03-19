package com.example.prm_smart_task.dto.kanban;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateTaskStatusRequest(
        @NotBlank(message = "Status name is required")
        @Size(max = 100, message = "Status name must be at most 100 characters")
        String name
) {
}
