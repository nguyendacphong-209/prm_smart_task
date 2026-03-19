package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Task;

public interface TaskRepository extends JpaRepository<Task, UUID> {

    List<Task> findByProjectId(UUID projectId);
}
