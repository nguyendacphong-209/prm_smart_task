package com.example.prm_smart_task.feature.auth.service;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import com.example.prm_smart_task.feature.shared.exception.PasswordResetEmailException;

@Service
public class PasswordResetEmailService {

    private static final Logger logger = LoggerFactory.getLogger(PasswordResetEmailService.class);
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}");

    private final RestClient restClient;
    private final String publicApiKey;
    private final String privateApiKey;
    private final String fromEmail;
    private final String fromName;

    public PasswordResetEmailService(
            @Value("${mailjet.api-key-public:}") String publicApiKey,
            @Value("${mailjet.api-key-private:}") String privateApiKey,
            @Value("${app.mail.from-email:}") String fromEmail,
            @Value("${app.mail.from-name:PRM Smart Task}") String fromName) {
        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(Duration.ofSeconds(10));
        this.restClient = RestClient.builder()
                .baseUrl("https://api.mailjet.com/v3.1")
                .requestFactory(requestFactory)
                .build();
        this.publicApiKey = publicApiKey;
        this.privateApiKey = privateApiKey;
        this.fromEmail = fromEmail;
        this.fromName = fromName;
    }

    public void sendResetCode(String recipient, String resetCode) {
        if (publicApiKey.isBlank() || privateApiKey.isBlank() || fromEmail.isBlank()) {
            throw new PasswordResetEmailException("Mailjet email settings are missing");
        }

        String text = "We received a request to reset your PRM Smart Task password.\n\n"
                + "Enter this code in the app to choose a new password:\n"
                + resetCode + "\n\n"
                + "This code expires in 30 minutes. If you did not request this, you can ignore this email.";

        try {
            MailjetSendResponse response = restClient.post()
                    .uri("/send")
                    .headers(headers -> headers.setBasicAuth(publicApiKey, privateApiKey))
                    .body(Map.of("Messages", List.of(Map.of(
                            "From", Map.of("Email", fromEmail, "Name", fromName),
                            "To", List.of(Map.of("Email", recipient)),
                            "Subject", "PRM Smart Task password reset",
                            "TextPart", text))))
                    .retrieve()
                    .body(MailjetSendResponse.class);

            if (response == null || response.messages() == null || response.messages().isEmpty()
                    || !"success".equalsIgnoreCase(response.messages().getFirst().status())) {
                logger.error("Mailjet did not accept password reset email. responseStatus={}",
                        response == null || response.messages() == null || response.messages().isEmpty()
                                ? "missing"
                                : response.messages().getFirst().status());
                throw new PasswordResetEmailException("Mailjet did not accept the email");
            }
        } catch (RestClientResponseException exception) {
            logger.error("Mailjet rejected password reset email request. status={} providerError={}",
                    exception.getStatusCode(), safeProviderError(exception));
            throw new PasswordResetEmailException("Mailjet email request failed", exception);
        } catch (RestClientException exception) {
            logger.error("Mailjet request failed. exceptionType={} message={}",
                    exception.getClass().getSimpleName(), exception.getMessage());
            throw new PasswordResetEmailException("Mailjet email request failed", exception);
        }
    }

    private String safeProviderError(RestClientResponseException exception) {
        try {
            JsonNode response = OBJECT_MAPPER.readTree(exception.getResponseBodyAsString());
            String errorMessage = response.path("ErrorMessage").asText("");
            String errorInfo = response.path("ErrorInfo").asText("");
            String message = String.join("; ",
                    java.util.stream.Stream.of(errorMessage, errorInfo)
                            .filter(value -> !value.isBlank())
                            .toList());
            if (message.isBlank()) {
                return "No provider error message";
            }

            String safeMessage = EMAIL_PATTERN.matcher(message).replaceAll("[email]");
            if (!publicApiKey.isBlank()) {
                safeMessage = safeMessage.replace(publicApiKey, "[redacted]");
            }
            if (!privateApiKey.isBlank()) {
                safeMessage = safeMessage.replace(privateApiKey, "[redacted]");
            }
            return safeMessage;
        } catch (JsonProcessingException ignored) {
            return "Could not parse provider error response";
        }
    }

    private record MailjetSendResponse(
            @JsonProperty("Messages") List<MailjetMessageResult> messages) {
    }

    private record MailjetMessageResult(
            @JsonProperty("Status") String status) {
    }
}
