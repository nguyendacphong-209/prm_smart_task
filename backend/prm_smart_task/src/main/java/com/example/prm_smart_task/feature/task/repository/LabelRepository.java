package com.example.prm_smart_task.feature.task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.feature.task.entity.Label;

public interface LabelRepository extends JpaRepository<Label, UUID> {

    List<Label> findByProjectId(UUID projectId);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query(value = "DELETE FROM task_labels WHERE label_id = :labelId", nativeQuery = true)
    void detachFromTasks(@org.springframework.data.repository.query.Param("labelId") UUID labelId);
}