package com.example.prm_smart_task.dto.task;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for creating/updating task with optional image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskCreateUpdateRequestDto {
    
    @NotBlank(message = "Task title is required")
    private String title;
    
    private String description;
    
    private String priority;
    
    private String deadline;
    
    private String statusId;
    
    // Optional: image URL from Cloudinary or any external source
    private String imageUrl;
}
