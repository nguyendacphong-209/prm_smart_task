package com.smarttask.repository;

import com.smarttask.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByRecipientIdAndRead(UUID recipientId, boolean read);
    List<Notification> findByRecipientId(UUID recipientId);
    long countByRecipientIdAndRead(UUID recipientId, boolean read);
}
