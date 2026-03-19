package com.smarttask.service;

import com.smarttask.dto.request.TaskRequest;
import com.smarttask.dto.response.TaskResponse;
import com.smarttask.enums.TaskStatus;
import java.util.List;
import java.util.UUID;

public interface TaskService {
    TaskResponse createTask(TaskRequest request, UUID userId);
    TaskResponse getTask(UUID id);
    List<TaskResponse> getProjectTasks(UUID projectId);
    List<TaskResponse> getProjectTasksByStatus(UUID projectId, TaskStatus status);
    List<TaskResponse> getAssigneeTasks(UUID assigneeId);
    TaskResponse updateTask(UUID id, TaskRequest request);
    void deleteTask(UUID id);
    /** userId reserved for future authorization checks (e.g., only project member can assign) */
    void assignTask(UUID taskId, UUID assigneeId, UUID userId);
    /** userId reserved for future authorization checks (e.g., only assignee can move to DONE) */
    TaskResponse updateTaskStatus(UUID taskId, TaskStatus status, UUID userId);
}
