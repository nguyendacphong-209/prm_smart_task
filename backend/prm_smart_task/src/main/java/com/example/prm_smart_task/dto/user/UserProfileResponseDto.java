package com.example.prm_smart_task.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for user profile with avatar
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfileResponseDto {
    private String id;
    private String email;
    private String fullName;
    private String avatarUrl;
    private String createdAt;
}
