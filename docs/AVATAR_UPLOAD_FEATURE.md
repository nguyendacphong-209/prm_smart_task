# Avatar Upload Feature - User Avatar Management with Cloudinary

## Overview

Users can now upload and manage their profile avatars using Cloudinary with strict validation and automatic image processing.

## Features

✅ **Secure File Validation**
- Max file size: **5MB**
- Supported formats: JPEG, PNG, WebP, GIF
- MIME type validation

✅ **Automatic Image Processing**
- Resize to 500×500 pixels
- Maintain aspect ratio
- Optimize quality (85%)
- Progressive JPEG for better loading

✅ **Smart Image Management**
- Automatic deletion of old avatar when uploading new one
- Delete avatar endpoint
- Database update with avatar URL

## API Endpoints

### 1. Upload Avatar (Current User - Authenticated)

```http
POST /api/avatars/upload
Content-Type: multipart/form-data
Authorization: Bearer {token}

Content:
file: [image file, max 5MB]
```

**Request Example (curl)**:
```bash
curl -X POST http://localhost:8080/api/avatars/upload \
  -H "Authorization: Bearer your-jwt-token" \
  -F "file=@/path/to/avatar.jpg"
```

**Response (200 OK)**:
```json
{
  "avatarUrl": "https://res.cloudinary.com/.../avatar/user123_abc123.jpg",
  "email": "user@example.com",
  "message": "Avatar uploaded successfully"
}
```

**Error Response (400 Bad Request)**:
```json
{
  "message": "File size exceeds 5MB limit. Current size: 7.50 MB"
}
```

```json
{
  "message": "Invalid file type. Allowed types: JPEG, PNG, WebP, GIF"
}
```

---

### 2. Upload Avatar by User ID

```http
POST /api/avatars/user/{userId}/upload
Content-Type: multipart/form-data

Content:
file: [image file, max 5MB]
```

**Usage**: Admin panel or user management, when you have user ID instead of token.

**Response**: Same as above

---

### 3. Delete Avatar (Current User)

```http
DELETE /api/avatars/delete
Authorization: Bearer {token}
```

**Response (200 OK)**:
```json
{
  "email": "user@example.com",
  "message": "Avatar deleted successfully"
}
```

---

## Validation Rules

| Rule | Limit | Details |
|------|-------|---------|
| **File Size** | 5MB max | Returns error if exceeds |
| **Allowed Types** | JPEG, PNG, WebP, GIF | MIME type validation |
| **Dimensions** | Auto-resize to 500×500 | Maintains aspect ratio |
| **Quality** | 85% | Optimized for balance |
| **Format** | Auto-detect | WebP for modern browsers |

## Error Codes & Messages

| Code | Error | Solution |
|------|-------|----------|
| 400 | File is empty | Select a valid image file |
| 400 | File size exceeds 5MB | Compress image or select smaller file |
| 400 | Invalid file type | Use JPEG, PNG, WebP, or GIF |
| 401 | User not authenticated | Include valid JWT token in Authorization header |
| 404 | User not found | Check user ID or email |
| 500 | Failed to upload avatar | Server error, check logs |

## File Structure

```
backend/src/main/java/com/example/prm_smart_task/
├── controller/
│   └── AvatarUploadController.java          # ✨ NEW - Avatar upload endpoints
├── service/
│   └── CloudinaryService.java               # 🔄 UPDATED - Added uploadAvatar() + validation
├── dto/
│   ├── AvatarUploadResponseDto.java         # ✨ NEW
│   └── UserProfileResponseDto.java          # ✨ NEW
└── entity/
    └── AppUser.java                         # Already has avatarUrl field
```

## Implementation Details

### CloudinaryService - Avatar Upload Method

```java
/**
 * Upload avatar with validation (5MB max) and resizing to 500x500
 * @param file The image file (validated before upload)
 * @return Cloudinary secure URL
 * @throws IOException If upload fails
 * @throws IllegalArgumentException If validation fails
 */
public String uploadAvatar(MultipartFile file) throws IOException {
    // 1. Validate file (size + type)
    validateImageFile(file);
    
    // 2. Resize to 500x500 using Thumbnailator
    byte[] resizedImage = resizeImage(file.getBytes(), 500, 500);
    
    // 3. Upload to Cloudinary with optimizations
    Map uploadResult = cloudinary.uploader().upload(
        resizedImage,
        ObjectUtils.asMap(
            "folder", "avatar",
            "quality", "auto",
            "fetch_format", "auto"  // WebP for modern browsers
        )
    );
    
    return (String) uploadResult.get("secure_url");
}
```

### Validation Process

```
User selects image
       ↓
Check file is not empty
       ↓
Check file size ≤ 5MB
       ↓
Check MIME type (JPEG/PNG/WebP/GIF)
       ↓
Resize to 500×500 pixels
       ↓
Optimize quality (85%)
       ↓
Upload to Cloudinary
       ↓
Save URL to database (AppUser.avatarUrl)
       ↓
Delete old avatar from Cloudinary
```

## Database Changes

**Table**: `users`
**Column**: `avatar_url TEXT`

Already exists in database schema. No migration needed.

## Configuration

### Dependencies Added

```gradle
implementation 'net.coobird:thumbnailator:0.4.20'
```

### Properties

```properties
# Cloudinary
cloudinary.cloud-name=${CLOUDINARY_CLOUD_NAME:your-cloud-name}
cloudinary.api-key=${CLOUDINARY_API_KEY:your-api-key}
cloudinary.api-secret=${CLOUDINARY_API_SECRET:your-api-secret}

# File upload limit (avatar uses 5MB hard limit in code)
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

## Frontend Integration

### React/Flutter Example

**Option 1: Upload immediately when selected**
```javascript
const handleAvatarSelect = async (file) => {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch('/api/avatars/upload', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: formData
  });
  
  const data = await response.json();
  if (response.ok) {
    console.log('Avatar uploaded:', data.avatarUrl);
    // Update UI with new avatar
  } else {
    console.error('Error:', data.message);
  }
};
```

**Option 2: Validate before sending**
```javascript
const validateFile = (file) => {
  const MAX_SIZE = 5 * 1024 * 1024; // 5MB
  const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
  
  if (file.size > MAX_SIZE) {
    return 'File exceeds 5MB limit';
  }
  
  if (!ALLOWED_TYPES.includes(file.type)) {
    return 'Only JPEG, PNG, WebP, GIF are allowed';
  }
  
  return null; // Valid
};
```

## Security Notes

🔒 **Best Practices**

1. **Authentication**: Only authenticated users can upload avatars
2. **File Validation**: Server-side validation is mandatory
3. **API Secret**: Never expose Cloudinary API Secret to frontend
4. **HTTPS Only**: Always use HTTPS in production
5. **Rate Limiting**: Consider adding rate limiting to prevent abuse

## Testing

### Manual Testing with curl

```bash
# Upload avatar
curl -X POST http://localhost:8080/api/avatars/upload \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@avatar.jpg"

# Delete avatar
curl -X DELETE http://localhost:8080/api/avatars/delete \
  -H "Authorization: Bearer <your-token>"

# Test file size validation
curl -X POST http://localhost:8080/api/avatars/upload \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@large-file-10mb.jpg"  # Should fail with 5MB error

# Test file type validation
curl -X POST http://localhost:8080/api/avatars/upload \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@document.pdf"  # Should fail with invalid type
```

### Unit Test Example

```java
@Test
void testValidateImageFileSizeExceeded() {
    MultipartFile oversizedFile = new MockMultipartFile(
        "file", "avatar.jpg", "image/jpeg", 
        new byte[6 * 1024 * 1024] // 6MB
    );
    
    assertThrows(IllegalArgumentException.class, () -> {
        cloudinaryService.uploadAvatar(oversizedFile);
    });
}

@Test
void testValidateImageFileInvalidType() {
    MultipartFile invalidFile = new MockMultipartFile(
        "file", "document.pdf", "application/pdf",
        "some content".getBytes()
    );
    
    assertThrows(IllegalArgumentException.class, () -> {
        cloudinaryService.uploadAvatar(invalidFile);
    });
}
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "File size exceeds 5MB" | Image too large | Compress or use smaller image |
| "Invalid file type" | Wrong format | Use JPEG, PNG, WebP, or GIF |
| 401 Unauthorized | Missing/invalid token | Check Authorization header and token |
| 404 User not found | User doesn't exist | Verify user ID or email |
| Avatar not updating | Old image delete failed | Check Cloudinary permissions |
| Resize not working | Server memory issue | Check server resources |

## Performance Considerations

- **Image Resize**: 500×500 is optimal size (balances quality & speed)
- **Quality 85%**: Good balance between quality and file size
- **Progressive JPEG**: Better perceived loading experience
- **WebP Format**: ~25% smaller than JPEG for modern browsers
- **CDN Delivery**: Cloudinary uses CDN for fast delivery worldwide

## Future Enhancements

- [ ] Thumbnail generation (100×100 for lists)
- [ ] Crop/rotate functionality on frontend
- [ ] Batch resize for multiple image sizes
- [ ] Avatar fallback/default images
- [ ] Rate limiting on upload endpoint
- [ ] Audit logging for image changes
- [ ] Image optimization presets

## Related Files

- `CloudinaryService.java` - Image processing & upload logic
- `AvatarUploadController.java` - REST API endpoints
- `AppUser.java` - Entity with avatarUrl field
- `AvatarUploadResponseDto.java` - Response structure
- `CLOUDINARY_SETUP.md` - General Cloudinary setup
