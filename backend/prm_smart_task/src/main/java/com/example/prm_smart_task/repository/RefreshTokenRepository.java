package com.example.prm_smart_task.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.entity.RefreshToken;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    Optional<RefreshToken> findByTokenAndRevokedFalse(String token);

    void deleteByUserId(UUID userId);
}
