## Avatar Upload - Quick Reference

### 📋 Validation Rules
- ✅ Max 5MB file size
- ✅ Formats: JPEG, PNG, WebP, GIF
- ✅ Auto-resize to 500×500
- ✅ Quality optimization (85%)
- ✅ Auto-delete old avatar

### 🔗 Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/avatars/upload` | Upload avatar (authenticated user) |
| POST | `/api/avatars/user/{userId}/upload` | Upload avatar by user ID |
| DELETE | `/api/avatars/delete` | Delete avatar (authenticated user) |

### 📤 Upload Example

```bash
# Upload avatar
curl -X POST http://localhost:8080/api/avatars/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@avatar.jpg"

# Response on success
{
  "avatarUrl": "https://res.cloudinary.com/...",
  "email": "user@example.com",
  "message": "Avatar uploaded successfully"
}

# Response on error
{
  "message": "File size exceeds 5MB limit. Current size: 7.50 MB"
}
```

### 🚫 Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| File size exceeds 5MB | Image too large | Compress image to <5MB |
| Invalid file type | Wrong format | Use JPEG/PNG/WebP/GIF |
| User not authenticated | Missing token | Add Authorization header |
| User not found | Invalid user ID | Check user ID |

### 📦 Modified/New Files

**New Files**:
- `CloudinaryService.java` - Added `uploadAvatar()` method
- `AvatarUploadController.java` - Avatar endpoints
- `AvatarUploadResponseDto.java` - Response DTO
- `UserProfileResponseDto.java` - Profile DTO

**Updated Files**:
- `CloudinaryService.java` - Added validation & resize
- `build.gradle` - Added Thumbnailator dependency
- `application.properties` - Added comments

### 🔧 Code Integration

Use in service/controller:
```java
// Inject service
@Autowired
private CloudinaryService cloudinaryService;

// Upload avatar with validation
String avatarUrl = cloudinaryService.uploadAvatar(file);

// Save to database
user.setAvatarUrl(avatarUrl);
userRepository.save(user);
```

### 📚 Full Documentation

See `AVATAR_UPLOAD_FEATURE.md` for complete details including:
- Detailed API specifications
- Frontend integration examples
- Security best practices
- Troubleshooting guide
- Performance considerations
