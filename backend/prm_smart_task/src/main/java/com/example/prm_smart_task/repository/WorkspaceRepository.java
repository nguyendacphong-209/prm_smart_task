package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.Workspace;

public interface WorkspaceRepository extends JpaRepository<Workspace, UUID> {

    List<Workspace> findByOwnerId(UUID ownerId);

    Optional<Workspace> findByIdAndOwnerId(UUID workspaceId, UUID ownerId);
}
