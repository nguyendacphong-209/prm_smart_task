package com.smarttask.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class WorkspaceRequest {
    @NotBlank
    private String name;
    private String description;
}
