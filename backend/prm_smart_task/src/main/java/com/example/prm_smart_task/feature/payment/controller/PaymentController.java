package com.example.prm_smart_task.feature.payment.controller;

import java.util.Map;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.payment.CreatePaymentRequest;
import com.example.prm_smart_task.dto.payment.PaymentResponse;
import com.example.prm_smart_task.feature.payment.service.PaymentService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/create")
    public ResponseEntity<PaymentResponse> create(@Valid @RequestBody CreatePaymentRequest request,
            Authentication authentication) {
        return ResponseEntity.ok(paymentService.createPayment(authentication.getName(), request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentResponse> get(@PathVariable UUID id, Authentication authentication) {
        return ResponseEntity.ok(paymentService.getPayment(id, authentication.getName()));
    }

    @PostMapping("/payos/webhook")
    public ResponseEntity<Map<String, Object>> webhook(
            @RequestBody(required = false) Map<String, Object> payload) {
        if (payload == null || payload.isEmpty()) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Webhook endpoint is reachable"));
        }
        Object signature = payload.get("signature");
        if (signature == null || signature.toString().isBlank()) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Webhook endpoint is reachable"));
        }
        paymentService.handleWebhook(payload);
        return ResponseEntity.ok(Map.of("success", true, "message", "Webhook processed"));
    }

    @GetMapping("/payos/webhook")
    public ResponseEntity<Map<String, Object>> webhookHealthCheck() {
        return ResponseEntity.ok(Map.of("success", true, "message", "Webhook endpoint is reachable"));
    }
}
