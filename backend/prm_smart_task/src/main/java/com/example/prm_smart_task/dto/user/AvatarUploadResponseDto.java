package com.example.prm_smart_task.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for avatar upload response
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AvatarUploadResponseDto {
    private String avatarUrl;
    private String message;
    private String email;
}
