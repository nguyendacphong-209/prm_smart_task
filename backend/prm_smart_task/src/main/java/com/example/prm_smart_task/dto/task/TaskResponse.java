package com.example.prm_smart_task.dto.task;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record TaskResponse(
        UUID id,
        UUID projectId,
        UUID statusId,
        String title,
        String description,
        String priority,
        LocalDateTime deadline,
        UUID createdBy,
        LocalDateTime createdAt,
        List<TaskAssigneeResponse> assignees,
        List<TaskLabelResponse> labels
) {
}
