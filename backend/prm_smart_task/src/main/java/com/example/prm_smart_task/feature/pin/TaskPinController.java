package com.example.prm_smart_task.feature.pin;
import java.util.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.http.*;
import org.springframework.web.server.ResponseStatusException;
@RestController
@RequestMapping("/api")
public class TaskPinController {
    private final TaskPinService service;
    public TaskPinController(TaskPinService service) { this.service = service; }
    @GetMapping("/me/pinned-tasks")
    public List<TaskPinService.PinnedTask> list(Authentication auth) { return service.list(auth.getName()); }
    @PutMapping("/tasks/{taskId}/pin") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void pin(Authentication auth, @PathVariable UUID taskId) { service.pin(auth.getName(), taskId); }
    @DeleteMapping("/tasks/{taskId}/pin") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unpin(Authentication auth, @PathVariable UUID taskId) { service.unpin(auth.getName(), taskId); }
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String,String>> handle(ResponseStatusException error) {
        return ResponseEntity.status(error.getStatusCode()).body(Map.of("message", error.getReason()==null ? "Request failed" : error.getReason()));
    }
}
