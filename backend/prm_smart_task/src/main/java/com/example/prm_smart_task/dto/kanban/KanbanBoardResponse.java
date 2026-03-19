package com.example.prm_smart_task.dto.kanban;

import java.util.List;
import java.util.UUID;

public record KanbanBoardResponse(
        UUID projectId,
        String projectName,
        List<KanbanStatusColumnResponse> columns
) {
}
