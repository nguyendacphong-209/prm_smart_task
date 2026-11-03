package com.example.prm_smart_task.feature.label;
import java.util.UUID;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import jakarta.validation.Valid;
import com.example.prm_smart_task.dto.task.TaskLabelResponse;
@RestController
@RequestMapping("/api/projects/{projectId}/labels")
public class LabelController {
 @ExceptionHandler(org.springframework.web.server.ResponseStatusException.class)
 public org.springframework.http.ResponseEntity<java.util.Map<String,String>> accessError(org.springframework.web.server.ResponseStatusException error) {
  return org.springframework.http.ResponseEntity.status(error.getStatusCode()).body(java.util.Map.of("message", error.getReason()==null ? "Authentication required" : error.getReason()));
 }
 private final LabelService service;
 public LabelController(LabelService service) { this.service=service; }
 @PostMapping @ResponseStatus(HttpStatus.CREATED)
 public TaskLabelResponse create(Authentication auth,@PathVariable UUID projectId,@Valid @RequestBody LabelRequest request) {
  return service.create(auth.getName(),projectId,request);
 }
 @PutMapping("/{labelId}")
 public TaskLabelResponse update(Authentication auth,@PathVariable UUID projectId,@PathVariable UUID labelId,@Valid @RequestBody LabelRequest request) {
  return service.update(auth.getName(),projectId,labelId,request);
 }
 @DeleteMapping("/{labelId}") @ResponseStatus(HttpStatus.NO_CONTENT)
 public void delete(Authentication auth,@PathVariable UUID projectId,@PathVariable UUID labelId) {
  service.delete(auth.getName(),projectId,labelId);
 }
}
