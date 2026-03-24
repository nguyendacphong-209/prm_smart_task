package com.example.prm_smart_task.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for task with image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskResponseDto {
    private String id;
    private String title;
    private String description;
    private String imageUrl;
    private String priority;
    private String deadline;
    private String statusId;
    private String projectId;
    private String createdAt;
}
