package com.example.prm_smart_task.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for image upload response
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ImageUploadResponseDto {
    private String imageUrl;
    private String message;
}
