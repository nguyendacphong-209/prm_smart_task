package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Notification;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId);

    long countByUserIdAndIsReadFalse(UUID userId);

    Optional<Notification> findByIdAndUserId(UUID notificationId, UUID userId);
}
