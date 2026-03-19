package com.smarttask.dto.response;

import com.smarttask.enums.TaskPriority;
import com.smarttask.enums.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private UUID id;
    private String title;
    private String description;
    private TaskStatus status;
    private TaskPriority priority;
    private LocalDateTime deadline;
    private UUID assigneeId;
    private UUID projectId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
