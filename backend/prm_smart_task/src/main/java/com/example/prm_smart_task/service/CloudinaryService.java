package com.example.prm_smart_task.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import net.coobird.thumbnailator.Thumbnails;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service
public class CloudinaryService {

    private final Cloudinary cloudinary;

    // Constants for validation
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final List<String> ALLOWED_MIME_TYPES = Arrays.asList(
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/gif"
    );
    private static final int AVATAR_WIDTH = 500;
    private static final int AVATAR_HEIGHT = 500;

    public CloudinaryService(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    /**
     * Upload an image file to Cloudinary
     * 
     * @param file The image file to upload
     * @param folder Cloudinary folder path (e.g., "workspace", "project", "task")
     * @return The secure URL of the uploaded image
     * @throws IOException if upload fails
     */
    public String uploadImage(MultipartFile file, String folder) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        Map uploadResult = cloudinary.uploader().upload(
            file.getBytes(),
            ObjectUtils.asMap(
                "folder", folder,
                "resource_type", "auto",
                "quality", "auto",
                "fetch_format", "auto"
            )
        );

        return (String) uploadResult.get("secure_url");
    }

    /**
     * Upload avatar image with validation (max 5MB) and resizing
     * 
     * @param file The image file to upload
     * @return The secure URL of the uploaded avatar
     * @throws IOException if upload fails
     * @throws IllegalArgumentException if validation fails
     */
    public String uploadAvatar(MultipartFile file) throws IOException {
        // Validate file
        validateImageFile(file);

        // Resize image to 500x500
        byte[] resizedImage = resizeImage(file.getBytes(), AVATAR_WIDTH, AVATAR_HEIGHT);

        // Upload to Cloudinary
        Map uploadResult = cloudinary.uploader().upload(
            resizedImage,
            ObjectUtils.asMap(
                "folder", "avatar",
                "resource_type", "image",
                "quality", "auto",
                "fetch_format", "auto",
                "flags", "progressive"
            )
        );

        return (String) uploadResult.get("secure_url");
    }

    /**
     * Validate image file (size and type)
     * 
     * @param file The file to validate
     * @throws IllegalArgumentException if validation fails
     */
    private void validateImageFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        // Check file size (max 5MB)
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException(
                String.format("File size exceeds 5MB limit. Current size: %.2f MB",
                    file.getSize() / (1024.0 * 1024.0))
            );
        }

        // Check MIME type
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType)) {
            throw new IllegalArgumentException(
                "Invalid file type. Allowed types: JPEG, PNG, WebP, GIF"
            );
        }
    }

    /**
     * Resize image to specified dimensions
     * 
     * @param imageBytes The original image bytes
     * @param width Target width
     * @param height Target height
     * @return Resized image bytes
     * @throws IOException if resizing fails
     */
    private byte[] resizeImage(byte[] imageBytes, int width, int height) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        
        try {
            Thumbnails.of(new java.io.ByteArrayInputStream(imageBytes))
                .size(width, height)
                .outputQuality(0.85)
                .keepAspectRatio(true)
                .toOutputStream(outputStream);
        } catch (IOException e) {
            throw new IOException("Failed to resize image: " + e.getMessage());
        }

        return outputStream.toByteArray();
    }

    /**
     * Delete an image from Cloudinary by public ID
     * 
     * @param publicId The public ID of the image to delete
     * @throws IOException if deletion fails
     */
    public void deleteImage(String publicId) throws IOException {
        if (publicId == null || publicId.isEmpty()) {
            return;
        }
        cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
    }

    /**
     * Extract public ID from Cloudinary secure URL
     * 
     * @param secureUrl The secure URL from Cloudinary
     * @return The public ID
     */
    public String extractPublicId(String secureUrl) {
        if (secureUrl == null || secureUrl.isEmpty()) {
            return null;
        }
        // URL format: https://res.cloudinary.com/{cloud_name}/image/upload/v{version}/{public_id}.{format}
        try {
            String[] parts = secureUrl.split("/");
            String lastPart = parts[parts.length - 1]; // e.g., "{public_id}.{format}"
            return lastPart.substring(0, lastPart.lastIndexOf('.')); // Remove extension
        } catch (Exception e) {
            return null;
        }
    }
}
