package com.example.prm_smart_task.dto.task;

import java.util.UUID;

public record TaskLabelResponse(
        UUID id,
        String name,
        String color,
        UUID createdById,
        String creatorFullName
) {
}
