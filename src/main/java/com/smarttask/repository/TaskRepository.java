package com.smarttask.repository;

import com.smarttask.entity.Task;
import com.smarttask.enums.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface TaskRepository extends JpaRepository<Task, UUID> {
    List<Task> findByProjectId(UUID projectId);
    List<Task> findByAssigneeId(UUID assigneeId);
    List<Task> findByProjectIdAndStatus(UUID projectId, TaskStatus status);
}
