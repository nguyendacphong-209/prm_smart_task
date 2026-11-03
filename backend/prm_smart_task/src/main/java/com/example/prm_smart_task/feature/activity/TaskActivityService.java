package com.example.prm_smart_task.feature.activity;
import java.time.Instant;
import java.util.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.example.prm_smart_task.feature.task.entity.Task;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.task.repository.TaskAssignmentRepository;
@Service
public class TaskActivityService {
 private final TaskActivityRepository repository;
 private final TaskAssignmentRepository assignments;
 public TaskActivityService(TaskActivityRepository repository, TaskAssignmentRepository assignments) {
  this.repository=repository; this.assignments=assignments;
 }
 public Map<String,String> snapshot(Task task) {
  Map<String,String> values=new LinkedHashMap<>();
  values.put("title",task.getTitle()); values.put("description",task.getDescription());
  values.put("deadline",task.getDeadline()==null?null:task.getDeadline().toString());
  values.put("status",task.getStatus()==null?null:task.getStatus().getName()+" ["+task.getStatus().getId()+"]");
  values.put("assignees",assignments.findByTaskId(task.getId()).stream()
    .sorted(Comparator.comparing(a->a.getUser().getId()))
    .map(a->a.getUser().getFullName()+" <"+a.getUser().getEmail()+">")
    .collect(java.util.stream.Collectors.joining(", ")));
  return values;
 }
 @Transactional(propagation=org.springframework.transaction.annotation.Propagation.MANDATORY)
 public void record(Task task, AppUser actor, Map<String,String> before) {
  snapshot(task).forEach((field,value)-> {
   if (!Objects.equals(before.get(field),value)) {
    TaskActivity event=new TaskActivity(); event.setTaskId(task.getId());
    event.setActorId(actor.getId()); event.setActorName(actor.getFullName() == null || actor.getFullName().isBlank() ? actor.getEmail() : actor.getFullName().trim());
    event.setField(field); event.setOldValue(before.get(field)); event.setNewValue(value);
    event.setCreatedAt(Instant.now()); repository.save(event);
   }
  });
 }
}
