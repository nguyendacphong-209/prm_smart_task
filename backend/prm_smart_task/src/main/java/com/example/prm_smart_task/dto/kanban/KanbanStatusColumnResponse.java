package com.example.prm_smart_task.dto.kanban;

import java.util.List;
import java.util.UUID;

public record KanbanStatusColumnResponse(
        UUID id,
        String name,
        Integer position,
        List<KanbanTaskCardResponse> tasks
) {
}
