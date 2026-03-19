package com.smarttask.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.UUID;

@Data
public class CommentRequest {
    @NotBlank
    private String content;
    @NotNull
    private UUID taskId;
}
