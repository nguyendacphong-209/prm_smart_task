package com.example.prm_smart_task.feature.ai.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.feature.ai.dto.AiTaskAnalyzeRequest;
import com.example.prm_smart_task.feature.ai.dto.AiTaskAnalyzeResponse;
import com.example.prm_smart_task.feature.ai.service.AiService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    private final AiService aiService;

    public AiController(AiService aiService) {
        this.aiService = aiService;
    }

    @PostMapping("/analyze-task")
    public ResponseEntity<AiTaskAnalyzeResponse> analyzeTask(@Valid @RequestBody AiTaskAnalyzeRequest request) {
        AiTaskAnalyzeResponse response = aiService.analyzeTask(request);
        return ResponseEntity.ok(response);
    }
}
