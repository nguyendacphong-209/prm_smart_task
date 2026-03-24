package com.example.prm_smart_task.dto.workspace;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for creating/updating workspace with optional image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkspaceCreateUpdateRequestDto {
    
    @NotBlank(message = "Workspace name is required")
    private String name;
    
    // Optional: image URL from Cloudinary or any external source
    private String imageUrl;
}
