package com.example.prm_smart_task.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.WorkspaceMember;

public interface WorkspaceMemberRepository extends JpaRepository<WorkspaceMember, UUID> {

    boolean existsByWorkspaceIdAndUserId(UUID workspaceId, UUID userId);

    Optional<WorkspaceMember> findByWorkspaceIdAndUserId(UUID workspaceId, UUID userId);

    List<WorkspaceMember> findByWorkspaceId(UUID workspaceId);

    List<WorkspaceMember> findByUserId(UUID userId);
}
