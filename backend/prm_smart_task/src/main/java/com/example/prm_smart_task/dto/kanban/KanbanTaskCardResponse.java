package com.example.prm_smart_task.dto.kanban;

import java.time.LocalDateTime;
import java.util.UUID;

public record KanbanTaskCardResponse(
        UUID id,
        String title,
        String priority,
        LocalDateTime deadline,
        UUID statusId
) {
}
