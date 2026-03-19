package com.example.prm_smart_task.dto.collaboration;

import java.time.LocalDateTime;
import java.util.UUID;

public record AttachmentResponse(
        UUID id,
        UUID taskId,
        String fileName,
        String fileUrl,
        LocalDateTime uploadedAt
) {
}
