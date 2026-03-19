package com.example.prm_smart_task.dto.task;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateTaskRequest(
        @NotBlank(message = "Task title is required")
        @Size(max = 255, message = "Task title must be at most 255 characters")
        String title,

        @Size(max = 5000, message = "Description is too long")
        String description,

        @Size(max = 20, message = "Priority must be at most 20 characters")
        String priority,

        LocalDateTime deadline,

        @NotNull(message = "Task status is required")
        UUID statusId,

        List<UUID> assigneeIds,

        List<UUID> labelIds
) {
}
