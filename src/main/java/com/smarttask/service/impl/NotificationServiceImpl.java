package com.smarttask.service.impl;

import com.smarttask.dto.response.NotificationResponse;
import com.smarttask.entity.Notification;
import com.smarttask.entity.User;
import com.smarttask.enums.NotificationType;
import com.smarttask.exception.ResourceNotFoundException;
import com.smarttask.exception.UnauthorizedException;
import com.smarttask.repository.NotificationRepository;
import com.smarttask.repository.UserRepository;
import com.smarttask.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    public List<NotificationResponse> getUserNotifications(UUID userId) {
        return notificationRepository.findByRecipientId(userId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<NotificationResponse> getUnreadNotifications(UUID userId) {
        return notificationRepository.findByRecipientIdAndRead(userId, false)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void markAsRead(UUID id, UUID userId) {
        Notification notification = notificationRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        if (!notification.getRecipient().getId().equals(userId)) {
            throw new UnauthorizedException("Cannot mark another user's notification as read");
        }
        notification.setRead(true);
        notificationRepository.save(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(UUID userId) {
        List<Notification> unread = notificationRepository.findByRecipientIdAndRead(userId, false);
        unread.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(unread);
    }

    @Override
    @Transactional
    public void createNotification(NotificationType type, String message, UUID recipientId, UUID referenceId) {
        User recipient = userRepository.findById(recipientId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Notification notification = Notification.builder()
            .type(type)
            .message(message)
            .recipient(recipient)
            .referenceId(referenceId)
            .build();
        notificationRepository.save(notification);
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
            .id(notification.getId())
            .type(notification.getType())
            .message(notification.getMessage())
            .isRead(notification.isRead())
            .referenceId(notification.getReferenceId())
            .createdAt(notification.getCreatedAt())
            .build();
    }
}
