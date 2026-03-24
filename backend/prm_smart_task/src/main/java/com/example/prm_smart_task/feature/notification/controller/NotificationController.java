package com.example.prm_smart_task.feature.notification.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.notification.NotificationResponse;
import com.example.prm_smart_task.dto.notification.UnreadCountResponse;
import com.example.prm_smart_task.feature.notification.service.NotificationService;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getMyNotifications(Authentication authentication) {
        List<NotificationResponse> response = notificationService.getMyNotifications(authentication.getName());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/unread-count")
    public ResponseEntity<UnreadCountResponse> getUnreadCount(Authentication authentication) {
        UnreadCountResponse response = notificationService.getUnreadCount(authentication.getName());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<NotificationResponse> markAsRead(
            Authentication authentication,
            @PathVariable UUID notificationId) {
        NotificationResponse response = notificationService.markAsRead(authentication.getName(), notificationId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/read-all")
    public ResponseEntity<ApiMessageResponse> markAllAsRead(Authentication authentication) {
        ApiMessageResponse response = notificationService.markAllAsRead(authentication.getName());
        return ResponseEntity.ok(response);
    }
}
