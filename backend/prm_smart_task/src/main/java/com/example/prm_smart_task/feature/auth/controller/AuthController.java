package com.example.prm_smart_task.feature.auth.controller;

import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.prm_smart_task.dto.auth.AuthTokenResponse;
import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.auth.ChangePasswordRequest;
import com.example.prm_smart_task.dto.user.CurrentUserResponse;
import com.example.prm_smart_task.dto.auth.LoginRequest;
import com.example.prm_smart_task.dto.auth.LogoutRequest;
import com.example.prm_smart_task.dto.auth.RefreshTokenRequest;
import com.example.prm_smart_task.dto.auth.RegisterRequest;
import com.example.prm_smart_task.dto.user.UpdateProfileRequest;
import com.example.prm_smart_task.feature.auth.service.AuthService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthTokenResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthTokenResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthTokenResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthTokenResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthTokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        AuthTokenResponse response = authService.refresh(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiMessageResponse> logout(@Valid @RequestBody LogoutRequest request) {
        ApiMessageResponse response = authService.logout(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<CurrentUserResponse> me(Authentication authentication) {
        CurrentUserResponse response = authService.getCurrentUser(authentication.getName());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/me")
    public ResponseEntity<CurrentUserResponse> updateMe(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request) {
        CurrentUserResponse response = authService.updateCurrentUser(authentication.getName(), request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiMessageResponse> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request) {
        ApiMessageResponse response = authService.changePassword(authentication.getName(), request);
        return ResponseEntity.ok(response);
    }
}
