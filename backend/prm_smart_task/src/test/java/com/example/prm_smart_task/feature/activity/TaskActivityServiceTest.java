package com.example.prm_smart_task.feature.activity;
import org.junit.jupiter.api.*;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;
import java.util.*;
import java.time.LocalDateTime;
import com.example.prm_smart_task.feature.task.entity.*;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.task.repository.TaskAssignmentRepository;
class TaskActivityServiceTest {
 TaskActivityRepository repository;
 TaskAssignmentRepository assignments;
 TaskActivityService service;
 Task task;
 AppUser actor;
 @BeforeEach void setup() {
  repository=mock(TaskActivityRepository.class); assignments=mock(TaskAssignmentRepository.class);
  service=new TaskActivityService(repository,assignments);
  task=new Task(); task.setId(UUID.randomUUID()); task.setTitle("Before");
  when(assignments.findByTaskId(task.getId())).thenReturn(List.of());
  actor=new AppUser(); actor.setId(UUID.randomUUID()); actor.setFullName("Huy");
 }
 @Test void unchangedDoesNotWriteHistory() { service.record(task,actor,service.snapshot(task)); verifyNoInteractions(repository); }
 @Test void recordsAllChangedFieldsWithActorAndBeforeAfter() {
  var before=service.snapshot(task);
  task.setTitle("After"); task.setDescription("Description"); task.setDeadline(LocalDateTime.of(2026,11,1,10,0));
  var status=new TaskStatus(); status.setId(UUID.randomUUID()); status.setName("Done"); task.setStatus(status);
  service.record(task,actor,before);
  var captor=org.mockito.ArgumentCaptor.forClass(TaskActivity.class); verify(repository,times(4)).save(captor.capture());
  var events=captor.getAllValues(); assertEquals(Set.of("title","description","deadline","status"), events.stream().map(TaskActivity::getField).collect(java.util.stream.Collectors.toSet()));
  for(var event:events) { assertEquals(actor.getId(),event.getActorId()); assertEquals("Huy",event.getActorName()); assertEquals(task.getId(),event.getTaskId()); assertNotNull(event.getCreatedAt()); }
  assertEquals("Before",events.get(0).getOldValue()); assertEquals("After",events.get(0).getNewValue());
 }
 TaskAssignment assignment(String name) {
  var user=new AppUser(); user.setId(UUID.randomUUID()); user.setFullName(name); user.setEmail(name+"@example.com");
  var assignment=new TaskAssignment(); assignment.setUser(user); return assignment;
 }
 @Test void assigneeOrderDoesNotCreateFalseChange() {
  var a=assignment("A"); var b=assignment("B");
  when(assignments.findByTaskId(task.getId())).thenReturn(List.of(a,b)); var before=service.snapshot(task);
  when(assignments.findByTaskId(task.getId())).thenReturn(List.of(b,a)); service.record(task,actor,before); verifyNoInteractions(repository);
 }
 @Test void removingAllAssigneesIsRecorded() {
  when(assignments.findByTaskId(task.getId())).thenReturn(List.of(assignment("A"))); var before=service.snapshot(task);
  when(assignments.findByTaskId(task.getId())).thenReturn(List.of()); service.record(task,actor,before);
  var captor=org.mockito.ArgumentCaptor.forClass(TaskActivity.class); verify(repository).save(captor.capture());
  assertEquals("assignees",captor.getValue().getField()); assertEquals("",captor.getValue().getNewValue()); assertTrue(captor.getValue().getOldValue().contains("A@example.com"));
 }
 @Test void nullOrBlankActorNameFallsBackToEmail() {
  actor.setEmail("huy@example.com");
  for (String name : new String[]{null, "   "}) {
   actor.setFullName(name); var before=service.snapshot(task);
   task.setTitle(task.getTitle()+" changed"); service.record(task,actor,before);
  }
  var captor=org.mockito.ArgumentCaptor.forClass(TaskActivity.class);
  verify(repository,times(2)).save(captor.capture());
  for(var event:captor.getAllValues()) assertEquals("huy@example.com",event.getActorName());
 }}
