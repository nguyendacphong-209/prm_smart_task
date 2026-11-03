package com.example.prm_smart_task.dto.payment;

import java.time.LocalDateTime;
import java.util.UUID;

public record PaymentResponse(
        UUID id,
        long orderCode,
        long amount,
        String planCode,
        String status,
        String checkoutUrl,
        String qrCode,
        LocalDateTime createdAt,
        LocalDateTime vipExpiresAt) {}
