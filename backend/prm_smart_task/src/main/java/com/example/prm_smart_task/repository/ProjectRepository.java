package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Project;

public interface ProjectRepository extends JpaRepository<Project, UUID> {

    List<Project> findByWorkspaceId(UUID workspaceId);
}
