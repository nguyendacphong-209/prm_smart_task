## Avatar Upload Integration - User Service Update Example

If you have existing UserService/UserController, follow these patterns to integrate avatar functionality.

---

## Option 1: UserService - Add Avatar Update Method

```java
@Service
public class UserService {
    
    private final AppUserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    
    public UserService(
            AppUserRepository userRepository,
            CloudinaryService cloudinaryService) {
        this.userRepository = userRepository;
        this.cloudinaryService = cloudinaryService;
    }
    
    /**
     * Update user avatar
     */
    public UserProfileResponseDto updateAvatar(UUID userId, MultipartFile file) throws IOException {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        
        // Validate and upload avatar
        String avatarUrl = cloudinaryService.uploadAvatar(file);
        
        // Delete old avatar if exists
        if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
            try {
                String publicId = cloudinaryService.extractPublicId(user.getAvatarUrl());
                cloudinaryService.deleteImage(publicId);
            } catch (IOException e) {
                // Log but don't fail
                System.err.println("Failed to delete old avatar: " + e.getMessage());
            }
        }
        
        // Update user
        user.setAvatarUrl(avatarUrl);
        AppUser updated = userRepository.save(user);
        
        return mapToProfileDto(updated);
    }
    
    /**
     * Delete user avatar
     */
    public UserProfileResponseDto deleteAvatar(UUID userId) throws IOException {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        
        // Delete from Cloudinary
        if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) {
            String publicId = cloudinaryService.extractPublicId(user.getAvatarUrl());
            cloudinaryService.deleteImage(publicId);
            
            user.setAvatarUrl(null);
            userRepository.save(user);
        }
        
        return mapToProfileDto(user);
    }
    
    /**
     * Get user profile with avatar
     */
    public UserProfileResponseDto getUserProfile(UUID userId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        return mapToProfileDto(user);
    }
    
    private UserProfileResponseDto mapToProfileDto(AppUser user) {
        return UserProfileResponseDto.builder()
                .id(user.getId().toString())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .avatarUrl(user.getAvatarUrl())
                .createdAt(user.getCreatedAt().toString())
                .build();
    }
}
```

---

## Option 2: UserController - Avatar Endpoints

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    /**
     * Update current user avatar
     */
    @PostMapping("/avatar/upload")
    public ResponseEntity<UserProfileResponseDto> updateMyAvatar(
            @RequestParam("file") MultipartFile file,
            Authentication authentication) {
        try {
            String email = authentication.getName();
            AppUser user = userService.findByEmail(email);
            UserProfileResponseDto response = userService.updateAvatar(user.getId(), file);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            // File validation error
            return ResponseEntity.badRequest().build();
        } catch (IOException e) {
            // Upload error
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * Delete current user avatar
     */
    @DeleteMapping("/avatar")
    public ResponseEntity<UserProfileResponseDto> deleteMyAvatar(
            Authentication authentication) {
        try {
            String email = authentication.getName();
            AppUser user = userService.findByEmail(email);
            UserProfileResponseDto response = userService.deleteAvatar(user.getId());
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * Get user profile with avatar
     */
    @GetMapping("/{userId}")
    public ResponseEntity<UserProfileResponseDto> getUserProfile(@PathVariable UUID userId) {
        UserProfileResponseDto response = userService.getUserProfile(userId);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get current user profile
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponseDto> getMyProfile(Authentication authentication) {
        String email = authentication.getName();
        AppUser user = userService.findByEmail(email);
        UserProfileResponseDto response = userService.getUserProfile(user.getId());
        return ResponseEntity.ok(response);
    }
}
```

---

## Option 3: AuthService - Include Avatar in Registration

```java
@Service
public class AuthService {
    
    private final AppUserRepository userRepository;
    
    /**
     * Register new user (avatar optional)
     */
    public UserProfileResponseDto register(UserRegistrationDto dto) {
        // Create user
        AppUser user = new AppUser();
        user.setEmail(dto.getEmail());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setFullName(dto.getFullName());
        user.setAvatarUrl(null); // Default no avatar
        
        AppUser saved = userRepository.save(user);
        
        return UserProfileResponseDto.builder()
                .id(saved.getId().toString())
                .email(saved.getEmail())
                .fullName(saved.getFullName())
                .avatarUrl(saved.getAvatarUrl())
                .createdAt(saved.getCreatedAt().toString())
                .build();
    }
}
```

---

## Option 4: Update User DTO to Include Avatar

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateRequestDto {
    
    @NotBlank
    private String fullName;
    
    private String avatarUrl; // Optional: set to existing Cloudinary URL
}

// In UserService
public UserProfileResponseDto updateUser(UUID userId, UserUpdateRequestDto dto) {
    AppUser user = userRepository.findById(userId)
            .orElseThrow(() -> new EntityNotFoundException("User not found"));
    
    user.setFullName(dto.getFullName());
    
    // Only update avatar if provided
    if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isEmpty()) {
        user.setAvatarUrl(dto.getAvatarUrl());
    }
    
    AppUser updated = userRepository.save(user);
    return mapToProfileDto(updated);
}
```

---

## Usage Patterns

### Pattern 1: Upload + Save in One Request
```
Frontend
  ↓
POST /api/avatars/upload (file)
  ↓
Backend AvatarUploadController
  ↓
Validate → Resize → Upload to Cloudinary → Save URL in DB
  ↓
Return avatarUrl
```

### Pattern 2: Get Profile with Avatar
```
GET /api/users/me
  ↓
Return UserProfileResponseDto
  {
    "id": "...",
    "email": "...",
    "fullName": "...",
    "avatarUrl": "https://res.cloudinary.com/.../avatar.jpg",
    "createdAt": "..."
  }
```

### Pattern 3: Delete Avatar
```
DELETE /api/avatars/delete
  ↓
Delete from Cloudinary
  ↓
Clear avatarUrl from DB
  ↓
Return success
```

---

## Testing Integration

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserAvatarIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private AppUserRepository userRepository;
    
    private String userToken;
    
    @Before
    void setup() {
        // Create test user and get token
        // ...
    }
    
    @Test
    void testUploadAvatar() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
            "file", "avatar.jpg", "image/jpeg",
            Files.readAllBytes(Paths.get("test-avatar.jpg"))
        );
        
        mockMvc.perform(multipart("/api/avatars/upload")
                .file(file)
                .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.avatarUrl").exists());
    }
    
    @Test
    void testUploadAvatarFileTooLarge() throws Exception {
        byte[] largeFile = new byte[6 * 1024 * 1024]; // 6MB
        MockMultipartFile file = new MockMultipartFile(
            "file", "avatar.jpg", "image/jpeg", largeFile
        );
        
        mockMvc.perform(multipart("/api/avatars/upload")
                .file(file)
                .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(containsString("5MB")));
    }
    
    @Test
    void testDeleteAvatar() throws Exception {
        // First upload
        // Then delete
        
        mockMvc.perform(delete("/api/avatars/delete")
                .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isOk());
        
        // Verify avatar is null in DB
        AppUser user = userRepository.findByEmail("test@example.com").orElseThrow();
        assertNull(user.getAvatarUrl());
    }
}
```

---

## Notes

- Always inject `CloudinaryService` for avatar operations
- Use `mapToProfileDto()` to convert entity to DTO
- Handle old avatar deletion gracefully (log error but don't fail)
- Include avatarUrl in all user response DTOs
- Validate file on both backend (already done) and frontend
