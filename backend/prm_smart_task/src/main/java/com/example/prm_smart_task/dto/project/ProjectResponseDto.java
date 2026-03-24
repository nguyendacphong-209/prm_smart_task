package com.example.prm_smart_task.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for project with image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectResponseDto {
    private String id;
    private String name;
    private String description;
    private String imageUrl;
    private String workspaceId;
    private String createdAt;
}
