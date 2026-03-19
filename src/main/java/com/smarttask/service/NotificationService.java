package com.smarttask.service;

import com.smarttask.dto.response.NotificationResponse;
import com.smarttask.enums.NotificationType;
import java.util.List;
import java.util.UUID;

public interface NotificationService {
    List<NotificationResponse> getUserNotifications(UUID userId);
    List<NotificationResponse> getUnreadNotifications(UUID userId);
    void markAsRead(UUID id, UUID userId);
    void markAllAsRead(UUID userId);
    void createNotification(NotificationType type, String message, UUID recipientId, UUID referenceId);
}
