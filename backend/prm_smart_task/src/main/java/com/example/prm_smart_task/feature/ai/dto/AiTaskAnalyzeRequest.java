package com.example.prm_smart_task.feature.ai.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiTaskAnalyzeRequest {

    @NotBlank(message = "Task title is required")
    private String taskTitle;

    private String taskDescription;
}
