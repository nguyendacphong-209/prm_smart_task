package com.example.prm_smart_task.feature.project.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.feature.project.entity.Project;

public interface ProjectRepository extends JpaRepository<Project, UUID> {

    List<Project> findByWorkspaceId(UUID workspaceId);
}
