package com.example.prm_smart_task.dto.workspace;

import java.util.UUID;

public record WorkspaceMemberResponse(
        UUID id,
        UUID workspaceId,
        UUID userId,
        String email,
        String fullName,
        String avatarUrl,
        String role,
        String invitationStatus
) {
}
