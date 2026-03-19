package com.example.prm_smart_task.dto.collaboration;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateCommentRequest(
        @NotBlank(message = "Comment content is required")
        @Size(max = 5000, message = "Comment content is too long")
        String content
) {
}
