package com.example.prm_smart_task.feature.activity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
public interface TaskActivityRepository extends JpaRepository<TaskActivity, UUID> {
 Page<TaskActivity> findByTaskIdOrderByCreatedAtDescIdDesc(UUID taskId, Pageable pageable);
}
