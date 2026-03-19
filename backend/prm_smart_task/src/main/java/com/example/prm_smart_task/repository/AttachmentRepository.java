package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Attachment;

public interface AttachmentRepository extends JpaRepository<Attachment, UUID> {

    List<Attachment> findByTaskIdOrderByUploadedAtDesc(UUID taskId);
}
