package com.example.prm_smart_task.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UuidGenerator;

@Entity
@Table(name = "attachments")
@Getter
@Setter
public class Attachment {

    @Id
    @GeneratedValue
    @UuidGenerator
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    @Column(name = "file_url", columnDefinition = "TEXT")
    private String fileUrl;

    @Column(name = "file_name", length = 255)
    private String fileName;

    @CreationTimestamp
    @Column(name = "uploaded_at", nullable = false, updatable = false)
    private LocalDateTime uploadedAt;
}
