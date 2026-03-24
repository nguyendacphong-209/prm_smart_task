package com.example.prm_smart_task.feature.task.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.feature.task.entity.TaskStatus;

public interface TaskStatusRepository extends JpaRepository<TaskStatus, UUID> {

    Optional<TaskStatus> findByIdAndProjectId(UUID statusId, UUID projectId);

    List<TaskStatus> findByProjectIdOrderByPositionAsc(UUID projectId);

    boolean existsByProjectIdAndNameIgnoreCase(UUID projectId, String name);

    Optional<TaskStatus> findTopByProjectIdOrderByPositionDesc(UUID projectId);
}