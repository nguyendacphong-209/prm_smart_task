package com.example.prm_smart_task.feature.ai.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.prm_smart_task.feature.ai.dto.AiTaskAnalyzeRequest;
import com.example.prm_smart_task.feature.ai.dto.AiTaskAnalyzeResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AiService {

    @Value("${gemini.api-key:}")
    private String geminiApiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiTaskAnalyzeResponse analyzeTask(AiTaskAnalyzeRequest request) {
        String title = request.getTaskTitle() != null ? request.getTaskTitle().trim() : "";
        String desc = request.getTaskDescription() != null ? request.getTaskDescription().trim() : "";

        if (geminiApiKey != null && !geminiApiKey.isBlank()) {
            try {
                return callGeminiApi(title, desc);
            } catch (Exception e) {
                // System.err.println("Gemini API call failed, falling back to smart generator: " + e.getMessage());
            }
        }

        return generateSmartFallback(title, desc);
    }

    private AiTaskAnalyzeResponse callGeminiApi(String title, String desc) throws Exception {
        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + geminiApiKey;

        String prompt = "You are an AI Project Management Assistant. Analyze the following task and respond ONLY in valid JSON format without markdown code blocks:\n"
                + "Task Title: " + title + "\n"
                + "Task Description: " + desc + "\n\n"
                + "Respond with this exact JSON structure:\n"
                + "{\n"
                + "  \"suggestedPriority\": \"HIGH\" | \"MEDIUM\" | \"LOW\",\n"
                + "  \"estimatedHours\": number,\n"
                + "  \"aiSummary\": \"string in Vietnamese summarizing the task objective\",\n"
                + "  \"suggestedSubtasks\": [\"string 1 in Vietnamese\", \"string 2 in Vietnamese\", \"string 3 in Vietnamese\", \"string 4 in Vietnamese\"]\n"
                + "}";

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))
                )
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode textNode = rootNode.path("candidates").get(0).path("content").path("parts").get(0).path("text");
            if (!textNode.isMissingNode()) {
                String rawText = textNode.asText().trim();
                if (rawText.startsWith("```json")) {
                    rawText = rawText.substring(7);
                }
                if (rawText.startsWith("```")) {
                    rawText = rawText.substring(3);
                }
                if (rawText.endsWith("```")) {
                    rawText = rawText.substring(0, rawText.length() - 3);
                }
                rawText = rawText.trim();

                JsonNode jsonRes = objectMapper.readTree(rawText);
                String priority = jsonRes.path("suggestedPriority").asText("MEDIUM").toUpperCase();
                int hours = jsonRes.path("estimatedHours").asInt(4);
                String summary = jsonRes.path("aiSummary").asText("Task " + title);

                List<String> subtasks = new ArrayList<>();
                JsonNode subNode = jsonRes.path("suggestedSubtasks");
                if (subNode.isArray()) {
                    for (JsonNode item : subNode) {
                        subtasks.add(item.asText());
                    }
                }

                return AiTaskAnalyzeResponse.builder()
                        .suggestedPriority(priority)
                        .estimatedHours(hours)
                        .aiSummary(summary)
                        .suggestedSubtasks(subtasks)
                        .build();
            }
        }

        return generateSmartFallback(title, desc);
    }

    private AiTaskAnalyzeResponse generateSmartFallback(String title, String desc) {
        String lowerTitle = (title + " " + desc).toLowerCase();
        List<String> subtasks = new ArrayList<>();
        String priority = "MEDIUM";
        int hours = 4;
        String summary;

        if (lowerTitle.contains("auth") || lowerTitle.contains("login") || lowerTitle.contains("register") || lowerTitle.contains("xác thực") || lowerTitle.contains("đăng nhập")) {
            priority = "HIGH";
            hours = 8;
            summary = "Xây dựng tính năng xác thực và phân quyền người dùng bảo mật với JWT.";
            subtasks.add("Thiết kế UI Form Đăng ký & Đăng nhập (Validation input)");
            subtasks.add("Viết REST API AuthController (/api/auth/register & /login)");
            subtasks.add("Mã hóa mật khẩu BCrypt & Cấu hình JWT Provider");
            subtasks.add("Xử lý Refresh Token & Lưu trữ AuthStorage an toàn");
            subtasks.add("Viết Unit & Integration Test kiểm thử luồng Auth");
        } else if (lowerTitle.contains("database") || lowerTitle.contains("db") || lowerTitle.contains("sql") || lowerTitle.contains("migration") || lowerTitle.contains("cơ sở dữ liệu")) {
            priority = "HIGH";
            hours = 6;
            summary = "Thiết kế và tối ưu hóa cấu trúc cơ sở dữ liệu PostgreSQL cho dự án.";
            subtasks.add("Thiết kế sơ đồ ERD & Mối quan hệ giữa các bảng");
            subtasks.add("Viết kịch bản database.sql & file migration");
            subtasks.add("Tạo JPA Entities, Repositories & Audit fields (createdAt/updatedAt)");
            subtasks.add("Đánh chỉ mục (Index) & Tối ưu hóa các câu truy vấn SQL");
        } else if (lowerTitle.contains("ui") || lowerTitle.contains("flutter") || lowerTitle.contains("giao diện") || lowerTitle.contains("screen") || lowerTitle.contains("kanban")) {
            priority = "MEDIUM";
            hours = 5;
            summary = "Phát triển và hoàn thiện giao diện Flutter theo chuẩn Material Design.";
            subtasks.add("Thiết kế Responsive Widget UI Layout");
            subtasks.add("Quản lý trạng thái màn hình với Riverpod Provider");
            subtasks.add("Kết nối REST API Client (Dio) & Xử lý Token Interceptor");
            subtasks.add("Thêm hiệu ứng Loading, Error Handling & AppMessenger notification");
        } else if (lowerTitle.contains("notification") || lowerTitle.contains("thông báo") || lowerTitle.contains("push")) {
            priority = "MEDIUM";
            hours = 4;
            summary = "Tích hợp hệ thống gửi thông báo cho thành viên trong Workspace.";
            subtasks.add("Xây dựng Notification Service & Repository ở Backend");
            subtasks.add("Tạo API lấy danh sách thông báo & Đánh dấu đã đọc");
            subtasks.add("Thiết kế UI Notification Center trên Mobile App");
        } else {
            priority = "MEDIUM";
            hours = 4;
            summary = "Lập kế hoạch và triển khai công việc '" + title + "' theo mục tiêu dự án.";
            subtasks.add("Phân tích chi tiết yêu cầu kỹ thuật & UI/UX");
            subtasks.add("Thiết kế cấu trúc dữ liệu và API Endpoints");
            subtasks.add("Lập trình chức năng chính và xử lý trường hợp lỗi (Edge Cases)");
            subtasks.add("Kiểm thử tính năng (Unit Test / UI Test) & Viết tài liệu hướng dẫn");
        }

        return AiTaskAnalyzeResponse.builder()
                .suggestedPriority(priority)
                .estimatedHours(hours)
                .aiSummary(summary)
                .suggestedSubtasks(subtasks)
                .build();
    }
}
