package com.example.prm_smart_task.feature.user.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.prm_smart_task.feature.user.entity.AppUser;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {

    boolean existsByEmail(String email);

    Optional<AppUser> findByEmail(String email);
}
