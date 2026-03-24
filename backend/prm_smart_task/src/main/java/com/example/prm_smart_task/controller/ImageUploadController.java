package com.example.prm_smart_task.controller;

import com.example.prm_smart_task.dto.ImageUploadResponseDto;
import com.example.prm_smart_task.entity.Project;
import com.example.prm_smart_task.entity.Task;
import com.example.prm_smart_task.entity.Workspace;
import com.example.prm_smart_task.repository.ProjectRepository;
import com.example.prm_smart_task.repository.TaskRepository;
import com.example.prm_smart_task.repository.WorkspaceRepository;
import com.example.prm_smart_task.service.CloudinaryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

/**
 * Controller for handling image uploads to Cloudinary
 */
@RestController
@RequestMapping("/api/images")
public class ImageUploadController {

    private final CloudinaryService cloudinaryService;
    private final WorkspaceRepository workspaceRepository;
    private final ProjectRepository projectRepository;
    private final TaskRepository taskRepository;

    public ImageUploadController(
            CloudinaryService cloudinaryService,
            WorkspaceRepository workspaceRepository,
            ProjectRepository projectRepository,
            TaskRepository taskRepository) {
        this.cloudinaryService = cloudinaryService;
        this.workspaceRepository = workspaceRepository;
        this.projectRepository = projectRepository;
        this.taskRepository = taskRepository;
    }

    /**
     * Upload workspace image
     * 
     * @param workspaceId The workspace ID
     * @param file The image file to upload
     * @return ImageUploadResponseDto with image URL
     */
    @PostMapping("/workspace/{workspaceId}/upload")
    public ResponseEntity<ImageUploadResponseDto> uploadWorkspaceImage(
            @PathVariable UUID workspaceId,
            @RequestParam("file") MultipartFile file) {
        try {
            // Check if workspace exists
            Workspace workspace = workspaceRepository.findById(workspaceId)
                    .orElseThrow(() -> new IllegalArgumentException("Workspace not found"));

            // Delete old image if exists
            if (workspace.getImageUrl() != null && !workspace.getImageUrl().isEmpty()) {
                String publicId = cloudinaryService.extractPublicId(workspace.getImageUrl());
                cloudinaryService.deleteImage(publicId);
            }

            // Upload new image
            String imageUrl = cloudinaryService.uploadImage(file, "workspace");
            workspace.setImageUrl(imageUrl);
            workspaceRepository.save(workspace);

            return ResponseEntity.ok(ImageUploadResponseDto.builder()
                    .imageUrl(imageUrl)
                    .message("Workspace image uploaded successfully")
                    .build());
        } catch (IOException e) {
            return ResponseEntity.badRequest()
                    .body(ImageUploadResponseDto.builder()
                            .message("Failed to upload image: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Upload project image
     * 
     * @param projectId The project ID
     * @param file The image file to upload
     * @return ImageUploadResponseDto with image URL
     */
    @PostMapping("/project/{projectId}/upload")
    public ResponseEntity<ImageUploadResponseDto> uploadProjectImage(
            @PathVariable UUID projectId,
            @RequestParam("file") MultipartFile file) {
        try {
            // Check if project exists
            Project project = projectRepository.findById(projectId)
                    .orElseThrow(() -> new IllegalArgumentException("Project not found"));

            // Delete old image if exists
            if (project.getImageUrl() != null && !project.getImageUrl().isEmpty()) {
                String publicId = cloudinaryService.extractPublicId(project.getImageUrl());
                cloudinaryService.deleteImage(publicId);
            }

            // Upload new image
            String imageUrl = cloudinaryService.uploadImage(file, "project");
            project.setImageUrl(imageUrl);
            projectRepository.save(project);

            return ResponseEntity.ok(ImageUploadResponseDto.builder()
                    .imageUrl(imageUrl)
                    .message("Project image uploaded successfully")
                    .build());
        } catch (IOException e) {
            return ResponseEntity.badRequest()
                    .body(ImageUploadResponseDto.builder()
                            .message("Failed to upload image: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Upload task image
     * 
     * @param taskId The task ID
     * @param file The image file to upload
     * @return ImageUploadResponseDto with image URL
     */
    @PostMapping("/task/{taskId}/upload")
    public ResponseEntity<ImageUploadResponseDto> uploadTaskImage(
            @PathVariable UUID taskId,
            @RequestParam("file") MultipartFile file) {
        try {
            // Check if task exists
            Task task = taskRepository.findById(taskId)
                    .orElseThrow(() -> new IllegalArgumentException("Task not found"));

            // Delete old image if exists
            if (task.getImageUrl() != null && !task.getImageUrl().isEmpty()) {
                String publicId = cloudinaryService.extractPublicId(task.getImageUrl());
                cloudinaryService.deleteImage(publicId);
            }

            // Upload new image
            String imageUrl = cloudinaryService.uploadImage(file, "task");
            task.setImageUrl(imageUrl);
            taskRepository.save(task);

            return ResponseEntity.ok(ImageUploadResponseDto.builder()
                    .imageUrl(imageUrl)
                    .message("Task image uploaded successfully")
                    .build());
        } catch (IOException e) {
            return ResponseEntity.badRequest()
                    .body(ImageUploadResponseDto.builder()
                            .message("Failed to upload image: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Delete image by URL
     * 
     * @param imageUrl The Cloudinary image URL to delete
     * @return Response message
     */
    @DeleteMapping("/delete")
    public ResponseEntity<ImageUploadResponseDto> deleteImage(
            @RequestParam String imageUrl) {
        try {
            String publicId = cloudinaryService.extractPublicId(imageUrl);
            cloudinaryService.deleteImage(publicId);
            return ResponseEntity.ok(ImageUploadResponseDto.builder()
                    .message("Image deleted successfully")
                    .build());
        } catch (IOException e) {
            return ResponseEntity.badRequest()
                    .body(ImageUploadResponseDto.builder()
                            .message("Failed to delete image: " + e.getMessage())
                            .build());
        }
    }
}
