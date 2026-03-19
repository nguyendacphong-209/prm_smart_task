package com.example.prm_smart_task.dto.dashboard;

import java.util.Map;
import java.util.UUID;

public record ProjectDashboardResponse(
        UUID projectId,
        String projectName,
        double completionPercentage,
        long totalTasks,
        long completedTasks,
        Map<String, Long> tasksByStatus,
        Map<String, Long> tasksByPriority
) {
}
