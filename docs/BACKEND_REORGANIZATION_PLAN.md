# Backend Folder Structure Reorganization Plan

## Current Structure (❌ Not Ideal)
```
com/example/prm_smart_task/
├── PrmSmartTaskApplication.java
├── controller/
│   ├── AuthController.java
│   ├── AvatarUploadController.java
│   ├── ProjectController.java
│   ├── TaskController.java
│   ├── WorkspaceController.java
│   └── ... (10+ controllers mixed)
├── entity/
│   ├── AppUser.java
│   ├── Project.java
│   ├── Task.java
│   └── ... (12 entities mixed)
├── dto/
│   ├── {generic DTOs}
│   ├── auth/
│   ├── project/
│   ├── task/
│   └── ... (DTOs partially organized)
├── service/
│   ├── AuthService.java
│   ├── ProjectService.java
│   └── ... (services mixed)
├── repository/ (all repos mixed)
├── config/
├── exception/
└── security/
```

**Problems**:
- ❌ Hard to find code for specific feature
- ❌ Mixing concerns (entity Workspace near entity RefreshToken)
- ❌ Controllers not grouped by feature
- ❌ Services scattered
- ❌ Difficult to understand relationships

---

## Proposed Structure (✅ Feature-Based)

```
com/example/prm_smart_task/
│
├── auth/                              # Authentication feature
│   ├── controller/
│   │   └── AuthController.java
│   ├── service/
│   │   └── AuthService.java
│   ├── dto/
│   │   ├── LoginRequestDto.java
│   │   ├── RegisterRequestDto.java
│   │   └── AuthResponseDto.java
│   └── security/
│       └── JwtTokenProvider.java
│
├── user/                              # User management feature
│   ├── controller/
│   │   └── UserController.java
│   ├── service/
│   │   └── UserService.java
│   ├── dto/
│   │   ├── UserProfileResponseDto.java
│   │   ├── UserUpdateRequestDto.java
│   │   └── AvatarUploadResponseDto.java
│   ├── entity/
│   │   └── AppUser.java
│   ├── repository/
│   │   └── AppUserRepository.java
│   └── controller/
│       └── AvatarUploadController.java
│
├── workspace/                         # Workspace feature
│   ├── controller/
│   │   └── WorkspaceController.java
│   ├── service/
│   │   └── WorkspaceService.java
│   ├── dto/
│   │   ├── WorkspaceCreateUpdateRequestDto.java
│   │   └── WorkspaceResponseDto.java
│   ├── entity/
│   │   ├── Workspace.java
│   │   └── WorkspaceMember.java
│   └── repository/
│       ├── WorkspaceRepository.java
│       └── WorkspaceMemberRepository.java
│
├── project/                           # Project feature
│   ├── controller/
│   │   └── ProjectController.java
│   ├── service/
│   │   └── ProjectService.java
│   ├── dto/
│   │   ├── ProjectCreateUpdateRequestDto.java
│   │   └── ProjectResponseDto.java
│   ├── entity/
│   │   └── Project.java
│   └── repository/
│       └── ProjectRepository.java
│
├── task/                              # Task feature
│   ├── controller/
│   │   └── TaskController.java
│   ├── service/
│   │   └── TaskService.java
│   ├── dto/
│   │   ├── TaskCreateUpdateRequestDto.java
│   │   └── TaskResponseDto.java
│   ├── entity/
│   │   ├── Task.java
│   │   ├── TaskStatus.java
│   │   ├── TaskAssignment.java
│   │   └── Attachment.java
│   └── repository/
│       ├── TaskRepository.java
│       ├── TaskStatusRepository.java
│       ├── TaskAssignmentRepository.java
│       └── AttachmentRepository.java
│
├── notification/                      # Notification feature
│   ├── controller/
│   │   └── NotificationController.java
│   ├── service/
│   │   └── NotificationService.java
│   ├── dto/ (placeholder)
│   ├── entity/
│   │   └── Notification.java
│   └── repository/
│       └── NotificationRepository.java
│
├── collaboration/                     # Collaboration feature (cross-feature)
│   ├── service/
│   │   └── CollaborationService.java
│   └── dto/
│       └── {collaboration DTOs}
│
├── kanban/                            # Kanban view feature
│   ├── controller/
│   │   └── KanbanController.java
│   ├── service/
│   │   └── KanbanService.java
│   └── dto/
│       └── {kanban DTOs}
│
├── dashboard/                         # Dashboard feature
│   ├── controller/
│   │   └── DashboardController.java
│   ├── service/
│   │   └── DashboardService.java
│   └── dto/
│       └── {dashboard DTOs}
│
├── shared/                            # Shared across all features
│   ├── config/
│   │   ├── CloudinaryConfig.java
│   │   └── {other configs}
│   ├── exception/
│   │   ├── EntityNotFoundException.java
│   │   ├── UnauthorizedException.java
│   │   └── {other exceptions}
│   ├── security/
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── SecurityConfig.java
│   │   └── WorkspaceAuthGuard.java
│   ├── service/
│   │   ├── CloudinaryService.java
│   │   └── {other shared services}
│   ├── utils/
│   │   ├── ValidationUtil.java
│   │   └── {utility classes}
│   ├── dto/
│   │   ├── CommonErrorResponseDto.java
│   │   └── {shared DTOs}
│   ├── entity/ (if any shared entity models)
│   └── constants/
│       └── AppConstants.java
│
├── PrmSmartTaskApplication.java
└── resources/
    ├── application.properties
    ├── application-dev.properties
    ├── migrations/
    └── db/
```

---

## Benefits of Feature-Based Structure

✅ **Easy Navigation**
- All code for "user" feature in one folder
- Find UserController, UserService, User DTOs, AppUser entity together

✅ **Clear Dependencies**
- Easy to see what each feature depends on
- Reduce circular dependencies

✅ **Scalability**
- Add new feature = add new folder
- Remove feature = delete folder

✅ **Team Organization**
- Each team handles one feature folder
- Clear ownership boundaries

✅ **Testing**
- Test all user feature tests in one place
- Organize test structure same as source

---

## Migration Steps

### Phase 1: Create new folder structure
- [ ] Create feature folders (user/, workspace/, project/, task/, etc.)
- [ ] Create subfolder structure (controller/, service/, dto/, entity/, repository/)

### Phase 2: Move files gradually
- [ ] Start with user feature (smallest, least dependencies)
- [ ] Then workspace
- [ ] Then project
- [ ] Then task
- [ ] Then others

### Phase 3: Update imports
- [ ] Update package declarations
- [ ] Update all imports in moved files
- [ ] Update imports in dependent files
- [ ] Run build to verify

### Phase 4: Cleanup
- [ ] Remove empty old folders
- [ ] Verify all tests pass
- [ ] Commit changes

---

## Detailed Structure per Feature

### User Feature Example
```
user/
├── controller/
│   ├── UserController.java          (GET /users, GET /users/{id}, PUT /users/{id})
│   └── AvatarUploadController.java  (POST /avatars/upload, DELETE /avatars)
├── service/
│   └── UserService.java             (User business logic)
├── dto/
│   ├── UserProfileResponseDto.java
│   ├── UserUpdateRequestDto.java
│   └── AvatarUploadResponseDto.java
├── entity/
│   └── AppUser.java
└── repository/
    └── AppUserRepository.java
```

### Task Feature Example
```
task/
├── controller/
│   └── TaskController.java
├── service/
│   └── TaskService.java
├── dto/
│   ├── TaskCreateUpdateRequestDto.java
│   └── TaskResponseDto.java
├── entity/
│   ├── Task.java
│   ├── TaskStatus.java
│   ├── TaskAssignment.java
│   └── Attachment.java
└── repository/
    ├── TaskRepository.java
    ├── TaskStatusRepository.java
    ├── TaskAssignmentRepository.java
    └── AttachmentRepository.java
```

### Workspace Feature Example
```
workspace/
├── controller/
│   └── WorkspaceController.java
├── service/
│   └── WorkspaceService.java
├── dto/
│   ├── WorkspaceCreateUpdateRequestDto.java
│   └── WorkspaceResponseDto.java
├── entity/
│   ├── Workspace.java
│   └── WorkspaceMember.java
└── repository/
    ├── WorkspaceRepository.java
    └── WorkspaceMemberRepository.java
```

---

## File Mapping: Old → New

### User Feature
```
entity/AppUser.java                    → user/entity/AppUser.java
controller/AvatarUploadController.java → user/controller/AvatarUploadController.java
repository/AppUserRepository.java      → user/repository/AppUserRepository.java
dto/UserProfileResponseDto.java        → user/dto/UserProfileResponseDto.java
dto/AvatarUploadResponseDto.java       → user/dto/AvatarUploadResponseDto.java
service/AuthService.java               → auth/service/AuthService.java (separate)
```

### Workspace Feature
```
entity/Workspace.java                  → workspace/entity/Workspace.java
entity/WorkspaceMember.java            → workspace/entity/WorkspaceMember.java
controller/WorkspaceController.java    → workspace/controller/WorkspaceController.java
service/WorkspaceService.java          → workspace/service/WorkspaceService.java
repository/WorkspaceRepository.java    → workspace/repository/WorkspaceRepository.java
repository/WorkspaceMemberRepository.java → workspace/repository/WorkspaceMemberRepository.java
dto/WorkspaceCreateUpdateRequestDto.java → workspace/dto/WorkspaceCreateUpdateRequestDto.java
dto/WorkspaceResponseDto.java          → workspace/dto/WorkspaceResponseDto.java
```

### Task Feature
```
entity/Task.java                       → task/entity/Task.java
entity/TaskStatus.java                 → task/entity/TaskStatus.java
entity/TaskAssignment.java             → task/entity/TaskAssignment.java
entity/Attachment.java                 → task/entity/Attachment.java
controller/TaskController.java         → task/controller/TaskController.java
service/TaskService.java               → task/service/TaskService.java
repository/TaskRepository.java         → task/repository/TaskRepository.java
repository/TaskStatusRepository.java   → task/repository/TaskStatusRepository.java
repository/TaskAssignmentRepository.java → task/repository/TaskAssignmentRepository.java
repository/AttachmentRepository.java   → task/repository/AttachmentRepository.java
dto/TaskCreateUpdateRequestDto.java    → task/dto/TaskCreateUpdateRequestDto.java
dto/TaskResponseDto.java               → task/dto/TaskResponseDto.java
```

### Project Feature
```
entity/Project.java                    → project/entity/Project.java
controller/ProjectController.java      → project/controller/ProjectController.java
service/ProjectService.java            → project/service/ProjectService.java
repository/ProjectRepository.java      → project/repository/ProjectRepository.java
dto/ProjectCreateUpdateRequestDto.java → project/dto/ProjectCreateUpdateRequestDto.java
dto/ProjectResponseDto.java            → project/dto/ProjectResponseDto.java
```

### Notification Feature
```
entity/Notification.java               → notification/entity/Notification.java
controller/NotificationController.java → notification/controller/NotificationController.java
service/NotificationService.java       → notification/service/NotificationService.java
repository/NotificationRepository.java → notification/repository/NotificationRepository.java
```

### Cross-Feature (Shared)
```
config/CloudinaryConfig.java           → shared/config/CloudinaryConfig.java
service/CloudinaryService.java         → shared/service/CloudinaryService.java
security/*                             → shared/security/
exception/*                            → shared/exception/
dto/ImageUploadResponseDto.java        → shared/dto/ImageUploadResponseDto.java
```

### Auth Feature
```
controller/AuthController.java         → auth/controller/AuthController.java
service/AuthService.java               → auth/service/AuthService.java
entity/RefreshToken.java               → auth/entity/RefreshToken.java
repository/RefreshTokenRepository.java → auth/repository/RefreshTokenRepository.java
```

---

## Questions to Answer Before Reorganizing

1. **Collaboration Service Location**: Is it shared across all features or specific to one?
   - Currently: `shared/service/CollaborationService.java`

2. **Kanban Service Location**: Is it a view across tasks or part of task feature?
   - Option A: `task/service/KanbanService.java` (part of task)
   - Option B: `shared/service/KanbanService.java` (cross-feature view)

3. **Dashboard Service**: Is it aggregating from multiple features?
   - Likely: `shared/service/DashboardService.java` (cross-feature)

4. **ImageUploadController**: Handle workspace, project, task images?
   - Option A: Keep in shared (uploads images for multiple entities)
   - Option B: Move to each entity folder separately

---

## Recommendations

1. **Start Small**: Begin with user feature (least dependencies)
2. **Move Gradually**: One feature at a time to avoid breaking imports
3. **Test After Each Move**: Run `./gradlew build` after each feature
4. **Update Documentation**: Update development guide with new structure
5. **Update IDE**: Configure IDE to recognize new package structure

---

## Next Steps

Choose one of:

**Option A: Manual Reorganization** (Full control)
- I guide you through moving files step-by-step
- You handle the file moves
- We verify imports after each step

**Option B: Scripted Reorganization** (Automated)
- Create script to move all files
- Script updates imports automatically
- Verify with build after

**Option C: Create New Structure** (Clean start)
- Create new folders with proper structure
- Copy/paste code into new locations
- Update imports all at once
- Verify with build
- Delete old folders

Which approach prefer? And do you want to start immediately or just get the plan first?
