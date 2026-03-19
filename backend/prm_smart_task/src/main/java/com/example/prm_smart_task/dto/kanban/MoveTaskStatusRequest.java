package com.example.prm_smart_task.dto.kanban;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;

public record MoveTaskStatusRequest(
        @NotNull(message = "Status id is required")
        UUID statusId
) {
}
