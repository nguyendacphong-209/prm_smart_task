package com.example.prm_smart_task.dto.payment;

import jakarta.validation.constraints.NotBlank;

public record CreatePaymentRequest(@NotBlank String planCode) {}
