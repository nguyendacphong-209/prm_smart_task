package com.example.prm_smart_task.feature.auth.service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.auth.AuthTokenResponse;
import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.auth.ChangePasswordRequest;
import com.example.prm_smart_task.dto.user.CurrentUserResponse;
import com.example.prm_smart_task.dto.auth.LoginRequest;
import com.example.prm_smart_task.dto.auth.LogoutRequest;
import com.example.prm_smart_task.dto.auth.RefreshTokenRequest;
import com.example.prm_smart_task.dto.auth.RegisterRequest;
import com.example.prm_smart_task.dto.user.UpdateProfileRequest;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.auth.entity.RefreshToken;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.auth.repository.RefreshTokenRepository;
import com.example.prm_smart_task.feature.shared.security.JwtService;

@Service
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final long refreshTokenExpirationMs;

    public AuthService(
            AppUserRepository appUserRepository,
            RefreshTokenRepository refreshTokenRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            @Value("${security.jwt.refresh-expiration-ms:604800000}") long refreshTokenExpirationMs) {
        this.appUserRepository = appUserRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenExpirationMs = refreshTokenExpirationMs;
    }

    @Transactional
    public AuthTokenResponse register(RegisterRequest request) {
        String normalizedEmail = request.email().trim().toLowerCase();
        if (appUserRepository.existsByEmail(normalizedEmail)) {
            throw new BadRequestException("Email is already registered");
        }

        AppUser appUser = new AppUser();
        appUser.setEmail(normalizedEmail);
        appUser.setPassword(passwordEncoder.encode(request.password()));
        appUser.setFullName(request.fullName());
        appUser.setAvatarUrl(request.avatarUrl());

        AppUser savedUser = appUserRepository.save(appUser);
        return issueTokens(savedUser);
    }

    @Transactional
    public AuthTokenResponse login(LoginRequest request) {
        String normalizedEmail = request.email().trim().toLowerCase();
        AppUser user = appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

        boolean passwordMatches = passwordEncoder.matches(request.password(), user.getPassword());
        if (!passwordMatches) {
            throw new UnauthorizedException("Invalid email or password");
        }

        return issueTokens(user);
    }

    @Transactional
    public AuthTokenResponse refresh(RefreshTokenRequest request) {
        RefreshToken storedToken = refreshTokenRepository.findByTokenAndRevokedFalse(request.refreshToken())
                .orElseThrow(() -> new UnauthorizedException("Invalid refresh token"));

        if (storedToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            storedToken.setRevoked(true);
            refreshTokenRepository.save(storedToken);
            throw new UnauthorizedException("Refresh token expired");
        }

        AppUser user = storedToken.getUser();
        storedToken.setRevoked(true);
        refreshTokenRepository.save(storedToken);

        return issueTokens(user);
    }

    @Transactional
    public ApiMessageResponse logout(LogoutRequest request) {
        refreshTokenRepository.findByToken(request.refreshToken()).ifPresent(refreshToken -> {
            if (!refreshToken.isRevoked()) {
                refreshToken.setRevoked(true);
                refreshTokenRepository.save(refreshToken);
            }
        });

        return new ApiMessageResponse("Logged out successfully");
    }

    private AuthTokenResponse issueTokens(AppUser user) {
        refreshTokenRepository.deleteByUserId(user.getId());

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getEmail());
        String refreshTokenValue = UUID.randomUUID().toString() + UUID.randomUUID().toString();
        LocalDateTime refreshTokenExpiresAt = LocalDateTime.now().plusSeconds(refreshTokenExpirationMs / 1000);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(refreshTokenValue);
        refreshToken.setExpiresAt(refreshTokenExpiresAt);
        refreshToken.setRevoked(false);
        refreshTokenRepository.save(refreshToken);

        return new AuthTokenResponse(
                accessToken,
                refreshTokenValue,
                "Bearer",
                jwtService.getAccessTokenExpirationMs(),
                refreshTokenExpirationMs,
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCreatedAt());
    }

    @Transactional(readOnly = true)
    public CurrentUserResponse getCurrentUser(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        AppUser user = appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        return mapToCurrentUserResponse(user);
    }

    @Transactional
    public CurrentUserResponse updateCurrentUser(String email, UpdateProfileRequest request) {
        String normalizedEmail = email.trim().toLowerCase();
        AppUser user = appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        if (request.fullName() != null) {
            String value = request.fullName().trim();
            user.setFullName(value.isBlank() ? null : value);
        }

        if (request.avatarUrl() != null) {
            String value = request.avatarUrl().trim();
            user.setAvatarUrl(value.isBlank() ? null : value);
        }

        AppUser updatedUser = appUserRepository.save(user);
        return mapToCurrentUserResponse(updatedUser);
    }

    @Transactional
    public ApiMessageResponse changePassword(String email, ChangePasswordRequest request) {
        String normalizedEmail = email.trim().toLowerCase();
        AppUser user = appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        if (!request.newPassword().equals(request.confirmNewPassword())) {
            throw new BadRequestException("Confirm new password does not match");
        }

        if (!passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw new UnauthorizedException("Current password is incorrect");
        }

        if (passwordEncoder.matches(request.newPassword(), user.getPassword())) {
            throw new BadRequestException("New password must be different from current password");
        }

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        appUserRepository.save(user);
        refreshTokenRepository.deleteByUserId(user.getId());

        return new ApiMessageResponse("Password changed successfully. Please login again.");
    }

    private CurrentUserResponse mapToCurrentUserResponse(AppUser user) {

        return new CurrentUserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCreatedAt());
    }
}
