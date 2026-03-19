package com.smarttask.controller;

import com.smarttask.dto.response.NotificationResponse;
import com.smarttask.entity.User;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.repository.NotificationRepository;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    private UUID getUserId(UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getId();
    }

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getAll(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(notificationService.getUserNotifications(getUserId(userDetails)));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@AuthenticationPrincipal UserDetails userDetails) {
        long count = notificationRepository.countByRecipientIdAndRead(getUserId(userDetails), false);
        return ResponseEntity.ok(Map.of("count", count));
    }

    @GetMapping("/unread")
    public ResponseEntity<List<NotificationResponse>> getUnread(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(notificationService.getUnreadNotifications(getUserId(userDetails)));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable UUID id,
                                            @AuthenticationPrincipal UserDetails userDetails) {
        notificationService.markAsRead(id, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@AuthenticationPrincipal UserDetails userDetails) {
        notificationService.markAllAsRead(getUserId(userDetails));
        return ResponseEntity.ok().build();
    }
}
