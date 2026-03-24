package com.example.prm_smart_task.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for creating/updating project with optional image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectCreateUpdateRequestDto {
    
    @NotBlank(message = "Project name is required")
    private String name;
    
    private String description;
    
    // Optional: image URL from Cloudinary or any external source
    private String imageUrl;
}
