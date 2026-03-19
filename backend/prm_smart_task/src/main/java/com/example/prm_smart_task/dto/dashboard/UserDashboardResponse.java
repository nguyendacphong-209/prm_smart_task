package com.example.prm_smart_task.dto.dashboard;

import java.util.Map;

public record UserDashboardResponse(
        long totalAssignedTasks,
        long completedTasks,
        long overdueTasks,
        long dueSoonTasks,
        Map<String, Long> tasksByPriority,
        Map<String, Long> tasksByStatus
) {
}
