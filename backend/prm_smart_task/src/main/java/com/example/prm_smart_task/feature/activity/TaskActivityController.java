package com.example.prm_smart_task.feature.activity;
import java.util.UUID;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.data.domain.*;
import org.springframework.transaction.annotation.Transactional;
import com.example.prm_smart_task.feature.task.repository.TaskRepository;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.feature.shared.exception.*;
@RestController
@RequestMapping("/api/tasks/{taskId}/activities")
public class TaskActivityController {
 private final TaskActivityRepository activities;
 private final TaskRepository tasks;
 private final AppUserRepository users;
 private final WorkspaceMemberRepository members;
 public TaskActivityController(TaskActivityRepository activities, TaskRepository tasks, AppUserRepository users, WorkspaceMemberRepository members) {
  this.activities=activities; this.tasks=tasks; this.users=users; this.members=members;
 }
 @GetMapping @Transactional(readOnly=true)
 public Page<TaskActivity> list(Authentication authentication, @PathVariable UUID taskId, @RequestParam(defaultValue="0") int page) {
  var user=users.findByEmail(authentication.getName()).orElseThrow(()->new UnauthorizedException("User not found"));
  var task=tasks.findById(taskId).orElseThrow(()->new BadRequestException("Task not found"));
  if(!members.existsByWorkspaceIdAndUserId(task.getProject().getWorkspace().getId(),user.getId())) throw new UnauthorizedException("You are not a member of this workspace");
  if(page<0) throw new BadRequestException("Invalid page");
  return activities.findByTaskIdOrderByCreatedAtDescIdDesc(taskId,PageRequest.of(page,20));
 }
}
