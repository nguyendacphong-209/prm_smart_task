package com.example.prm_smart_task.feature.payment.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.example.prm_smart_task.feature.payment.repository.PaymentOrderRepository;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import tools.jackson.databind.json.JsonMapper;

class PaymentServiceWebhookTest {
    private static final String CHECKSUM_KEY = "test-checksum-key";
    private static final long ORDER_CODE = 123456L;

    private PaymentOrderRepository orderRepository;
    private PaymentService paymentService;

    @BeforeEach
    void setUp() {
        orderRepository = mock(PaymentOrderRepository.class);
        paymentService = new PaymentService(
                orderRepository,
                mock(AppUserRepository.class),
                JsonMapper.builder().build(),
                "client-id",
                "api-key",
                CHECKSUM_KEY,
                "https://api-merchant.payos.vn",
                "https://example.com/success",
                "https://example.com/cancel");
    }

    @Test
    void acceptsValidSignatureWhenWebhookDataContainsNullValues() {
        when(orderRepository.findByOrderCode(ORDER_CODE)).thenReturn(Optional.empty());

        assertDoesNotThrow(() -> paymentService.handleWebhook(webhookPayload(signatureFor(
                "amount=49000&counterAccountName=&orderCode=123456&reference=txn-1"))));
    }

    @Test
    void rejectsWebhookWithInvalidSignature() {
        Map<String, Object> payload = webhookPayload("invalid-signature");

        assertThrows(BadRequestException.class, () -> paymentService.handleWebhook(payload));
    }

    private static Map<String, Object> webhookPayload(String signature) {
        Map<String, Object> data = new HashMap<>();
        data.put("amount", 49000);
        data.put("counterAccountName", null);
        data.put("orderCode", ORDER_CODE);
        data.put("reference", "txn-1");

        Map<String, Object> payload = new HashMap<>();
        payload.put("code", "00");
        payload.put("data", data);
        payload.put("signature", signature);
        return payload;
    }

    private static String signatureFor(String canonicalData) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(CHECKSUM_KEY.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] digest = mac.doFinal(canonicalData.getBytes(StandardCharsets.UTF_8));
            StringBuilder signature = new StringBuilder();
            for (byte value : digest) {
                signature.append(String.format("%02x", value));
            }
            return signature.toString();
        } catch (Exception exception) {
            throw new IllegalStateException(exception);
        }
    }
}
