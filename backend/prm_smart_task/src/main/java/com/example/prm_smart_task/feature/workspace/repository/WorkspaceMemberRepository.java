package com.example.prm_smart_task.feature.workspace.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.prm_smart_task.feature.workspace.entity.WorkspaceMember;

public interface WorkspaceMemberRepository extends JpaRepository<WorkspaceMember, UUID> {

    @Query("""
        select count(wm) > 0
        from WorkspaceMember wm
        where wm.workspace.id = :workspaceId
          and wm.user.id = :userId
          and wm.invitationStatus = 'accepted'
        """)
    boolean existsByWorkspaceIdAndUserId(UUID workspaceId, UUID userId);

    @Query("""
        select wm
        from WorkspaceMember wm
        where wm.workspace.id = :workspaceId
          and wm.user.id = :userId
          and wm.invitationStatus = 'accepted'
        """)
    Optional<WorkspaceMember> findByWorkspaceIdAndUserId(UUID workspaceId, UUID userId);

    List<WorkspaceMember> findByWorkspaceId(UUID workspaceId);

    List<WorkspaceMember> findByWorkspaceIdAndInvitationStatus(UUID workspaceId, String invitationStatus);

    @Query("""
        select wm
        from WorkspaceMember wm
        where wm.workspace.id = :workspaceId
          and wm.user.id = :userId
        """)
    Optional<WorkspaceMember> findAnyByWorkspaceIdAndUserId(
        @Param("workspaceId") UUID workspaceId,
        @Param("userId") UUID userId);

    @Query("""
        select count(wm) > 0
        from WorkspaceMember wm
        where wm.workspace.id = :workspaceId
          and wm.user.id = :userId
        """)
    boolean existsAnyByWorkspaceIdAndUserId(
        @Param("workspaceId") UUID workspaceId,
        @Param("userId") UUID userId);

    @Query("""
        select wm
        from WorkspaceMember wm
        where wm.user.id = :userId
          and wm.invitationStatus = 'accepted'
        """)
    List<WorkspaceMember> findByUserId(UUID userId);
}
