/**
 * EXAMPLE: How to use new DTOs with imageUrl in existing services
 * 
 * Copy these patterns to your existing WorkspaceService, ProjectService, TaskService
 */

// ============================================================
// EXAMPLE 1: WorkspaceService.createWorkspace()
// ============================================================

/*
@Service
public class WorkspaceService {
    
    private final WorkspaceRepository workspaceRepository;
    
    public WorkspaceResponseDto createWorkspace(
            WorkspaceCreateUpdateRequestDto dto,
            UUID ownerId) {
        
        Workspace workspace = new Workspace();
        workspace.setName(dto.getName());
        workspace.setImageUrl(dto.getImageUrl()); // Set imageUrl from request
        workspace.setOwner(new AppUser(); workspace.getOwner().setId(ownerId));
        
        Workspace saved = workspaceRepository.save(workspace);
        return mapToResponseDto(saved);
    }
    
    public WorkspaceResponseDto updateWorkspace(
            UUID workspaceId,
            WorkspaceCreateUpdateRequestDto dto) {
        
        Workspace workspace = workspaceRepository.findById(workspaceId)
                .orElseThrow(() -> new EntityNotFoundException("Workspace not found"));
        
        workspace.setName(dto.getName());
        
        // Update imageUrl only if provided
        if (dto.getImageUrl() != null) {
            workspace.setImageUrl(dto.getImageUrl());
        }
        
        Workspace updated = workspaceRepository.save(workspace);
        return mapToResponseDto(updated);
    }
    
    private WorkspaceResponseDto mapToResponseDto(Workspace workspace) {
        return WorkspaceResponseDto.builder()
                .id(workspace.getId().toString())
                .name(workspace.getName())
                .imageUrl(workspace.getImageUrl()) // Include imageUrl in response
                .ownerName(workspace.getOwner().getFullName())
                .createdAt(workspace.getCreatedAt().toString())
                .build();
    }
}
*/

// ============================================================
// EXAMPLE 2: WorkspaceController with imageUrl support
// ============================================================

/*
@RestController
@RequestMapping("/api/workspaces")
public class WorkspaceController {
    
    private final WorkspaceService workspaceService;
    
    @PostMapping
    public ResponseEntity<WorkspaceResponseDto> createWorkspace(
            @RequestBody @Valid WorkspaceCreateUpdateRequestDto dto,
            @AuthenticationPrincipal AppUser currentUser) {
        
        WorkspaceResponseDto response = workspaceService.createWorkspace(dto, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PutMapping("/{workspaceId}")
    public ResponseEntity<WorkspaceResponseDto> updateWorkspace(
            @PathVariable UUID workspaceId,
            @RequestBody @Valid WorkspaceCreateUpdateRequestDto dto) {
        
        WorkspaceResponseDto response = workspaceService.updateWorkspace(workspaceId, dto);
        return ResponseEntity.ok(response);
    }
}
*/

// ============================================================
// EXAMPLE 3: ProjectService with imageUrl
// ============================================================

/*
@Service
public class ProjectService {
    
    private final ProjectRepository projectRepository;
    
    public ProjectResponseDto createProject(
            UUID workspaceId,
            ProjectCreateUpdateRequestDto dto) {
        
        Project project = new Project();
        project.setName(dto.getName());
        project.setDescription(dto.getDescription());
        project.setImageUrl(dto.getImageUrl()); // Set imageUrl from request
        project.setWorkspace(new Workspace(); project.getWorkspace().setId(workspaceId));
        
        Project saved = projectRepository.save(project);
        return mapToResponseDto(saved);
    }
    
    public ProjectResponseDto updateProject(
            UUID projectId,
            ProjectCreateUpdateRequestDto dto) {
        
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new EntityNotFoundException("Project not found"));
        
        project.setName(dto.getName());
        project.setDescription(dto.getDescription());
        
        if (dto.getImageUrl() != null) {
            project.setImageUrl(dto.getImageUrl());
        }
        
        Project updated = projectRepository.save(project);
        return mapToResponseDto(updated);
    }
    
    private ProjectResponseDto mapToResponseDto(Project project) {
        return ProjectResponseDto.builder()
                .id(project.getId().toString())
                .name(project.getName())
                .description(project.getDescription())
                .imageUrl(project.getImageUrl()) // Include imageUrl in response
                .workspaceId(project.getWorkspace().getId().toString())
                .createdAt(project.getCreatedAt().toString())
                .build();
    }
}
*/

// ============================================================
// EXAMPLE 4: TaskService with imageUrl
// ============================================================

/*
@Service
public class TaskService {
    
    private final TaskRepository taskRepository;
    
    public TaskResponseDto createTask(
            UUID projectId,
            TaskCreateUpdateRequestDto dto) {
        
        Task task = new Task();
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setPriority(dto.getPriority());
        task.setImageUrl(dto.getImageUrl()); // Set imageUrl from request
        task.setProject(new Project(); task.getProject().setId(projectId));
        
        Task saved = taskRepository.save(task);
        return mapToResponseDto(saved);
    }
    
    public TaskResponseDto updateTask(
            UUID taskId,
            TaskCreateUpdateRequestDto dto) {
        
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new EntityNotFoundException("Task not found"));
        
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setPriority(dto.getPriority());
        
        if (dto.getImageUrl() != null) {
            task.setImageUrl(dto.getImageUrl());
        }
        
        Task updated = taskRepository.save(task);
        return mapToResponseDto(updated);
    }
    
    private TaskResponseDto mapToResponseDto(Task task) {
        return TaskResponseDto.builder()
                .id(task.getId().toString())
                .title(task.getTitle())
                .description(task.getDescription())
                .imageUrl(task.getImageUrl()) // Include imageUrl in response
                .priority(task.getPriority())
                .projectId(task.getProject().getId().toString())
                .createdAt(task.getCreatedAt().toString())
                .build();
    }
}
*/

// ============================================================
// USAGE FLOW IN FRONTEND
// ============================================================

/*
1. CREATE WITH IMAGE - Two Options:

Option A: Upload image first, then create entity
POST /api/images/workspace/{workspaceId}/upload
⬇️
GET imageUrl from response
⬇️
POST /api/workspaces
Body: { "name": "...", "imageUrl": "https://..." }

Option B: Create entity without image, upload later
POST /api/workspaces
Body: { "name": "..." }
⬇️
GET workspaceId from response
⬇️
POST /api/images/workspace/{workspaceId}/upload

2. UPDATE WITH IMAGE:

PUT /api/workspaces/{workspaceId}
Body: { "name": "...", "imageUrl": "https://..." }

3. DELETE ENTITY:

DELETE /api/workspaces/{workspaceId}
// Make sure to delete associated image if needed
DELETE /api/images/delete?imageUrl=...
*/
