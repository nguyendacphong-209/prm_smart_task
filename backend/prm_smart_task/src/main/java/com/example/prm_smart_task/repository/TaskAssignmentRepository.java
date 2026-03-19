package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.TaskAssignment;

public interface TaskAssignmentRepository extends JpaRepository<TaskAssignment, UUID> {

    List<TaskAssignment> findByTaskId(UUID taskId);

    List<TaskAssignment> findByUserId(UUID userId);

    void deleteByTaskId(UUID taskId);
}
