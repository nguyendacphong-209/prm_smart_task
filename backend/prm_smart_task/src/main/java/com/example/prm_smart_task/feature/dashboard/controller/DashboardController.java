package com.example.prm_smart_task.feature.dashboard.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.dashboard.ProjectDashboardResponse;
import com.example.prm_smart_task.dto.dashboard.UserDashboardResponse;
import com.example.prm_smart_task.feature.dashboard.service.DashboardService;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserDashboardResponse> getMyDashboard(Authentication authentication) {
        UserDashboardResponse response = dashboardService.getUserDashboard(authentication.getName());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/projects/{projectId}")
    public ResponseEntity<ProjectDashboardResponse> getProjectDashboard(
            Authentication authentication,
            @PathVariable UUID projectId) {
        ProjectDashboardResponse response = dashboardService.getProjectDashboard(authentication.getName(), projectId);
        return ResponseEntity.ok(response);
    }
}
