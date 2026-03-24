package com.example.prm_smart_task.dto.workspace;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for workspace with image URL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkspaceResponseDto {
    private String id;
    private String name;
    private String imageUrl;
    private String ownerName;
    private String createdAt;
}
