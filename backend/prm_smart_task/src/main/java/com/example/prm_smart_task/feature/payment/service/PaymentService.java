package com.example.prm_smart_task.feature.payment.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.payment.CreatePaymentRequest;
import com.example.prm_smart_task.dto.payment.PaymentResponse;
import com.example.prm_smart_task.feature.payment.entity.PaymentOrder;
import com.example.prm_smart_task.feature.payment.repository.PaymentOrderRepository;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@Service
public class PaymentService {
    private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);

    private final PaymentOrderRepository orderRepository;
    private final AppUserRepository userRepository;
    private final JsonMapper jsonMapper;
    private final String clientId;
    private final String apiKey;
    private final String checksumKey;
    private final String apiBaseUrl;
    private final String returnUrl;
    private final String cancelUrl;

    public PaymentService(PaymentOrderRepository orderRepository, AppUserRepository userRepository,
            JsonMapper jsonMapper,
            @Value("${payos.client-id:}") String clientId,
            @Value("${payos.api-key:}") String apiKey,
            @Value("${payos.checksum-key:}") String checksumKey,
            @Value("${payos.api-base-url:https://api-merchant.payos.vn}") String apiBaseUrl,
            @Value("${payos.return-url:http://localhost:8080/payment/success}") String returnUrl,
            @Value("${payos.cancel-url:http://localhost:8080/payment/cancel}") String cancelUrl) {
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.jsonMapper = jsonMapper;
        this.clientId = clientId;
        this.apiKey = apiKey;
        this.checksumKey = checksumKey;
        this.apiBaseUrl = apiBaseUrl;
        this.returnUrl = returnUrl;
        this.cancelUrl = cancelUrl;
    }

    @Transactional
    public PaymentResponse createPayment(String email, CreatePaymentRequest request) {
        AppUser user = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new UnauthorizedException("User not found"));
        Plan plan = switch (request.planCode().trim().toUpperCase()) {
            case "VIP_1_MONTH" -> new Plan("VIP_1_MONTH", 49000, 1);
            case "VIP_3_MONTH" -> new Plan("VIP_3_MONTH", 129000, 3);
            case "VIP_1_YEAR" -> new Plan("VIP_1_YEAR", 399000, 12);
            default -> throw new BadRequestException("Gói VIP không hợp lệ");
        };
        if (clientId.isBlank() || apiKey.isBlank() || checksumKey.isBlank()) {
            throw new BadRequestException("PayOS chưa được cấu hình. Thiếu PAYOS_CLIENT_ID, PAYOS_API_KEY hoặc PAYOS_CHECKSUM_KEY.");
        }

        long orderCode = Math.abs(UUID.randomUUID().getLeastSignificantBits());
        if (orderCode == 0) orderCode = Instant.now().toEpochMilli();
        String description = ("VIP " + request.planCode()).replace('_', ' ').substring(0, Math.min(25, ("VIP " + request.planCode()).replace('_', ' ').length()));
        String signature = hmacSha256("amount=" + plan.amount() + "&cancelUrl=" + cancelUrl + "&description=" + description + "&orderCode=" + orderCode + "&returnUrl=" + returnUrl, checksumKey);
        try {
            Map<String, Object> body = Map.of("orderCode", orderCode, "amount", plan.amount(), "description", description,
                    "cancelUrl", cancelUrl, "returnUrl", returnUrl, "signature", signature);
            HttpRequest httpRequest = HttpRequest.newBuilder().uri(URI.create(apiBaseUrl + "/v2/payment-requests"))
                    .header("Content-Type", "application/json").header("x-client-id", clientId).header("x-api-key", apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonMapper.writeValueAsString(body))).build();
            HttpResponse<String> response = HttpClient.newHttpClient().send(httpRequest, HttpResponse.BodyHandlers.ofString());
            JsonNode root = jsonMapper.readTree(response.body());
            if (response.statusCode() < 200 || response.statusCode() >= 300 || !"00".equals(root.path("code").asText())) {
                String payOsCode = root.path("code").asText("unknown");
                String payOsDescription = root.path("desc").asText("Lỗi không xác định");
                logger.warn("PayOS payment creation rejected: httpStatus={}, payOsCode={}, description={}",
                        response.statusCode(), payOsCode, payOsDescription);
                throw new BadRequestException("Không thể tạo thanh toán PayOS: " + payOsDescription);
            }
            JsonNode data = root.path("data");
            PaymentOrder order = new PaymentOrder();
            order.setUser(user); order.setOrderCode(orderCode); order.setAmount(plan.amount());
            order.setPlanCode(plan.code()); order.setStatus("PENDING");
            order.setCheckoutUrl(data.path("checkoutUrl").asText(null)); order.setQrCode(data.path("qrCode").asText(null));
            orderRepository.save(order);
            return map(order);
        } catch (BadRequestException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new BadRequestException("Không thể kết nối PayOS: " + exception.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public PaymentResponse getPayment(UUID id, String email) {
        PaymentOrder order = orderRepository.findByIdAndUserEmail(id, email.trim().toLowerCase())
                .orElseThrow(() -> new BadRequestException("Không tìm thấy đơn thanh toán"));
        if (!"PAID".equals(order.getStatus())) {
            syncPayOsStatus(order);
        }
        return map(order);
    }

    @Transactional
    public void handleWebhook(Map<String, Object> payload) {
        try {
            JsonNode root = jsonMapper.valueToTree(payload);
            JsonNode data = root.path("data");
            long orderCode = data.path("orderCode").asLong();
            String signature = root.path("signature").asText();
            if (signature.isBlank()) {
                logger.info("PayOS webhook probe received without a signature");
                return;
            }
            String computed = hmacSha256(canonicalData(data), checksumKey);
            if (!signature.equals(computed)) {
                logger.warn("PayOS webhook rejected: signature validation failed");
                throw new BadRequestException("Chữ ký webhook PayOS không hợp lệ");
            }
            logger.info("PayOS webhook signature validated");
            PaymentOrder order = orderRepository.findByOrderCode(orderCode)
                    .orElse(null);
            if (order == null) {
                logger.info("PayOS webhook validated but did not match a local payment order");
                return;
            }
            if ("00".equals(root.path("code").asText()) && data.path("code").asText().equals("00") && !"PAID".equals(order.getStatus())) {
                markPaid(order);
            }
        } catch (BadRequestException exception) { throw exception; }
        catch (Exception exception) { throw new BadRequestException("Webhook không hợp lệ"); }
    }

    private void syncPayOsStatus(PaymentOrder order) {
        if (clientId.isBlank() || apiKey.isBlank()) return;
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(apiBaseUrl + "/v2/payment-requests/" + order.getOrderCode()))
                    .header("x-client-id", clientId)
                    .header("x-api-key", apiKey)
                    .GET().build();
            HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                JsonNode root = jsonMapper.readTree(response.body());
                String status = root.path("data").path("status").asText("");
                if ("PAID".equalsIgnoreCase(status)) markPaid(order);
            }
        } catch (Exception ignored) { }
    }

    private void markPaid(PaymentOrder order) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime base = order.getUser().getVipExpiresAt() != null && order.getUser().getVipExpiresAt().isAfter(now)
                ? order.getUser().getVipExpiresAt() : now;
        Plan plan = switch (order.getPlanCode()) {
            case "VIP_1_MONTH" -> new Plan(order.getPlanCode(), 49000, 1);
            case "VIP_3_MONTH" -> new Plan(order.getPlanCode(), 129000, 3);
            case "VIP_1_YEAR" -> new Plan(order.getPlanCode(), 399000, 12);
            default -> throw new BadRequestException("Gói VIP không hợp lệ");
        };
        LocalDateTime expiresAt = base.plusMonths(plan.months());
        order.setStatus("PAID"); order.setPaidAt(now); order.setVipExpiresAt(expiresAt);
        order.getUser().setVip(true); order.getUser().setVipExpiresAt(expiresAt);
        orderRepository.save(order); userRepository.save(order.getUser());
    }

    private PaymentResponse map(PaymentOrder order) {
        return new PaymentResponse(order.getId(), order.getOrderCode(), order.getAmount(), order.getPlanCode(),
                order.getStatus(), order.getCheckoutUrl(), order.getQrCode(), order.getCreatedAt(), order.getVipExpiresAt());
    }

    private String canonicalData(JsonNode data) {
        try {
            java.util.TreeMap<String, String> sorted = new java.util.TreeMap<>();
            for (var entry : data.properties()) {
                JsonNode value = entry.getValue();
                sorted.put(entry.getKey(), value.isNull() ? ""
                        : value.isValueNode() ? value.asText() : value.toString());
            }
            StringBuilder result = new StringBuilder(); sorted.forEach((key, value) -> result.append(result.isEmpty() ? "" : "&").append(key).append('=').append(value));
            return result.toString();
        } catch (Exception exception) { return ""; }
    }

    private String hmacSha256(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256"); mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8)); StringBuilder hex = new StringBuilder();
            for (byte value : bytes) hex.append(String.format("%02x", value)); return hex.toString();
        } catch (Exception exception) { throw new IllegalStateException("Không thể ký dữ liệu PayOS", exception); }
    }

    private record Plan(String code, long amount, int months) {}
}
