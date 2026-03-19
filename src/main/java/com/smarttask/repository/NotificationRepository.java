package com.smarttask.repository;

import com.smarttask.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByRecipientIdAndRead(UUID recipientId, boolean read);
    List<Notification> findByRecipientId(UUID recipientId);
    long countByRecipientIdAndRead(UUID recipientId, boolean read);

    @Modifying
    @Query("UPDATE Notification n SET n.read = true WHERE n.recipient.id = :recipientId AND n.read = false")
    void markAllAsReadByRecipientId(@Param("recipientId") UUID recipientId);
}
