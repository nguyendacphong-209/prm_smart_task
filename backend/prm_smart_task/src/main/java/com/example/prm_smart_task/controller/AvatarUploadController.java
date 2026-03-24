package com.example.prm_smart_task.controller;

import com.example.prm_smart_task.dto.AvatarUploadResponseDto;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.service.CloudinaryService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

/**
 * Controller for handling avatar uploads to Cloudinary
 * Rules:
 * - File size max 5MB
 * - Supported formats: JPEG, PNG, WebP, GIF
 * - Image will be resized to 500x500 before upload
 */
@RestController
@RequestMapping("/api/avatars")
public class AvatarUploadController {

    private final CloudinaryService cloudinaryService;
    private final AppUserRepository appUserRepository;

    public AvatarUploadController(
            CloudinaryService cloudinaryService,
            AppUserRepository appUserRepository) {
        this.cloudinaryService = cloudinaryService;
        this.appUserRepository = appUserRepository;
    }

    /**
     * Upload user avatar with authentication
     * 
     * @param file The image file to upload (max 5MB)
     * @param authentication Spring Security authentication
     * @return AvatarUploadResponseDto with avatar URL
     */
    @PostMapping("/upload")
    public ResponseEntity<AvatarUploadResponseDto> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            Authentication authentication) {
        try {
            // Get current user from authentication
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(AvatarUploadResponseDto.builder()
                                .message("User not authenticated")
                                .build());
            }

            String userEmail = authentication.getName();
            AppUser user = appUserRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            // Validate and upload avatar
            String avatarUrl = cloudinaryService.uploadAvatar(file);

            // Delete old avatar if exists
            if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
                try {
                    String publicId = cloudinaryService.extractPublicId(user.getAvatarUrl());
                    cloudinaryService.deleteImage(publicId);
                } catch (IOException e) {
                    // Log but don't fail if old image deletion fails
                    System.err.println("Failed to delete old avatar: " + e.getMessage());
                }
            }

            // Update user with new avatar URL
            user.setAvatarUrl(avatarUrl);
            appUserRepository.save(user);

            return ResponseEntity.ok(AvatarUploadResponseDto.builder()
                    .avatarUrl(avatarUrl)
                    .email(user.getEmail())
                    .message("Avatar uploaded successfully")
                    .build());

        } catch (IllegalArgumentException e) {
            // File validation errors (size, type)
            return ResponseEntity.badRequest()
                    .body(AvatarUploadResponseDto.builder()
                            .message(e.getMessage())
                            .build());
        } catch (IOException e) {
            // Upload or processing errors
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(AvatarUploadResponseDto.builder()
                            .message("Failed to upload avatar: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Upload avatar by user ID (admin or user endpoint)
     * 
     * @param userId The user ID
     * @param file The image file to upload (max 5MB)
     * @return AvatarUploadResponseDto with avatar URL
     */
    @PostMapping("/user/{userId}/upload")
    public ResponseEntity<AvatarUploadResponseDto> uploadAvatarByUserId(
            @PathVariable UUID userId,
            @RequestParam("file") MultipartFile file) {
        try {
            // Check if user exists
            AppUser user = appUserRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            // Validate and upload avatar
            String avatarUrl = cloudinaryService.uploadAvatar(file);

            // Delete old avatar if exists
            if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
                try {
                    String publicId = cloudinaryService.extractPublicId(user.getAvatarUrl());
                    cloudinaryService.deleteImage(publicId);
                } catch (IOException e) {
                    System.err.println("Failed to delete old avatar: " + e.getMessage());
                }
            }

            // Update user with new avatar URL
            user.setAvatarUrl(avatarUrl);
            appUserRepository.save(user);

            return ResponseEntity.ok(AvatarUploadResponseDto.builder()
                    .avatarUrl(avatarUrl)
                    .email(user.getEmail())
                    .message("Avatar uploaded successfully")
                    .build());

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(AvatarUploadResponseDto.builder()
                            .message(e.getMessage())
                            .build());
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(AvatarUploadResponseDto.builder()
                            .message("Failed to upload avatar: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Delete user avatar
     * 
     * @param authentication Spring Security authentication
     * @return Response message
     */
    @DeleteMapping("/delete")
    public ResponseEntity<AvatarUploadResponseDto> deleteAvatar(Authentication authentication) {
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(AvatarUploadResponseDto.builder()
                                .message("User not authenticated")
                                .build());
            }

            String userEmail = authentication.getName();
            AppUser user = appUserRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            // Delete avatar from Cloudinary if exists
            if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
                String publicId = cloudinaryService.extractPublicId(user.getAvatarUrl());
                cloudinaryService.deleteImage(publicId);

                // Clear avatar URL from database
                user.setAvatarUrl(null);
                appUserRepository.save(user);
            }

            return ResponseEntity.ok(AvatarUploadResponseDto.builder()
                    .message("Avatar deleted successfully")
                    .email(user.getEmail())
                    .build());

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(AvatarUploadResponseDto.builder()
                            .message("Failed to delete avatar: " + e.getMessage())
                            .build());
        }
    }
}
