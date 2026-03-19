package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Comment;

public interface CommentRepository extends JpaRepository<Comment, UUID> {

    List<Comment> findByTaskIdOrderByCreatedAtAsc(UUID taskId);
}
