package com.example.prm_smart_task.feature.ai.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiTaskAnalyzeResponse {

    private String suggestedPriority; // HIGH, MEDIUM, LOW
    private Integer estimatedHours;
    private String aiSummary;
    private List<String> suggestedSubtasks;
}
