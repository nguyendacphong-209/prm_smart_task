package com.example.prm_smart_task.feature.auth.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.auth.AuthTokenResponse;
import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.auth.ChangePasswordRequest;
import com.example.prm_smart_task.dto.auth.ForgotPasswordRequest;
import com.example.prm_smart_task.dto.user.CurrentUserResponse;
import com.example.prm_smart_task.dto.auth.GoogleLoginRequest;
import com.example.prm_smart_task.dto.auth.LoginRequest;
import com.example.prm_smart_task.dto.auth.LogoutRequest;
import com.example.prm_smart_task.dto.auth.RefreshTokenRequest;
import com.example.prm_smart_task.dto.auth.RegisterRequest;
import com.example.prm_smart_task.dto.auth.ResetPasswordRequest;
import com.example.prm_smart_task.dto.user.UpdateProfileRequest;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.auth.entity.RefreshToken;
import com.example.prm_smart_task.feature.auth.entity.PasswordResetToken;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.auth.repository.RefreshTokenRepository;
import com.example.prm_smart_task.feature.auth.repository.PasswordResetTokenRepository;
import com.example.prm_smart_task.feature.shared.security.JwtService;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private static final String PASSWORD_RESET_MESSAGE =
            "If an account exists for that email, a password reset code has been sent.";
    private static final int RESET_CODE_BYTES = 32;
    private static final long RESET_CODE_EXPIRATION_MINUTES = 30;

    private final AppUserRepository appUserRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordResetEmailService passwordResetEmailService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final GoogleIdTokenVerifierService googleIdTokenVerifier;
    private final long refreshTokenExpirationMs;
    private final SecureRandom secureRandom = new SecureRandom();

    public AuthService(
            AppUserRepository appUserRepository,
            RefreshTokenRepository refreshTokenRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            PasswordResetEmailService passwordResetEmailService,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            GoogleIdTokenVerifierService googleIdTokenVerifier,
            @Value("${security.jwt.refresh-expiration-ms:604800000}") long refreshTokenExpirationMs) {
        this.appUserRepository = appUserRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordResetEmailService = passwordResetEmailService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
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
    public AuthTokenResponse loginWithGoogle(GoogleLoginRequest request) {
        GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
        String normalizedEmail = googleUser.email().trim().toLowerCase(Locale.ROOT);

        AppUser user = appUserRepository.findByEmail(normalizedEmail).orElseGet(() -> {
            AppUser newUser = new AppUser();
            newUser.setEmail(normalizedEmail);
            newUser.setFullName(
                    googleUser.name() == null || googleUser.name().isBlank()
                            ? "Google User"
                            : googleUser.name());
            newUser.setAvatarUrl(googleUser.pictureUrl());
            newUser.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
            return appUserRepository.save(newUser);
        });

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

    @Transactional
    public ApiMessageResponse requestPasswordReset(ForgotPasswordRequest request) {
        String normalizedEmail = request.email().trim().toLowerCase();
        AppUser user = appUserRepository.findByEmail(normalizedEmail).orElse(null);
        if (user == null) {
            return new ApiMessageResponse(PASSWORD_RESET_MESSAGE);
        }

        byte[] randomBytes = new byte[RESET_CODE_BYTES];
        secureRandom.nextBytes(randomBytes);
        String resetCode = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);

        passwordResetTokenRepository.deleteByUserId(user.getId());
        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setUser(user);
        resetToken.setTokenHash(hashToken(resetCode));
        resetToken.setExpiresAt(LocalDateTime.now().plusMinutes(RESET_CODE_EXPIRATION_MINUTES));
        passwordResetTokenRepository.save(resetToken);

        try {
            passwordResetEmailService.sendResetCode(user.getEmail(), resetCode);
        } catch (MailException exception) {
            logger.warn("Could not send password reset email for user {}", user.getId(), exception);
        }

        return new ApiMessageResponse(PASSWORD_RESET_MESSAGE);
    }

    @Transactional
    public ApiMessageResponse resetPassword(ResetPasswordRequest request) {
        if (!request.newPassword().equals(request.confirmNewPassword())) {
            throw new BadRequestException("Confirm new password does not match");
        }

        String normalizedEmail = request.email().trim().toLowerCase();
        PasswordResetToken resetToken = passwordResetTokenRepository
                .findByTokenHashAndExpiresAtAfter(hashToken(request.token()), LocalDateTime.now())
                .orElseThrow(() -> new BadRequestException("Reset code is invalid or expired"));

        AppUser user = resetToken.getUser();
        if (!user.getEmail().equals(normalizedEmail)) {
            throw new BadRequestException("Reset code is invalid or expired");
        }
        if (passwordEncoder.matches(request.newPassword(), user.getPassword())) {
            throw new BadRequestException("New password must be different from current password");
        }

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        appUserRepository.save(user);
        passwordResetTokenRepository.delete(resetToken);
        refreshTokenRepository.deleteByUserId(user.getId());

        return new ApiMessageResponse("Password reset successfully. Please login again.");
    }

    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    private CurrentUserResponse mapToCurrentUserResponse(AppUser user) {

        return new CurrentUserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCreatedAt(),
                user.isVip(),
                user.getVipExpiresAt());
    }
}
