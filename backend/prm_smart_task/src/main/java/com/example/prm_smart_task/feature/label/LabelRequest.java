package com.example.prm_smart_task.feature.label;
import jakarta.validation.constraints.*;
public record LabelRequest(@NotBlank @Size(max=100) String name,
                           @NotNull @Pattern(regexp="#[0-9a-fA-F]{6}") String color) {}
