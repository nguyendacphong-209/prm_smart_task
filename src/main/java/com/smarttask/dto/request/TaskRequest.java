package com.smarttask.dto.request;

import com.smarttask.enums.TaskPriority;
import com.smarttask.enums.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class TaskRequest {
    @NotBlank
    private String title;
    private String description;
    private TaskStatus status;
    private TaskPriority priority;
    private LocalDateTime deadline;
    private UUID assigneeId;
    @NotNull
    private UUID projectId;
}
