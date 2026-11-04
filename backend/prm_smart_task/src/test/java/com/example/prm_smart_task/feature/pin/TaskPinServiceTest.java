package com.example.prm_smart_task.feature.pin;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.*;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.web.server.ResponseStatusException;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
class TaskPinServiceTest {
 JdbcTemplate jdbc; AppUserRepository users; TaskPinService service;
 UUID userId=UUID.randomUUID(), taskId=UUID.randomUUID();
 @BeforeEach void setup() {
  jdbc=mock(JdbcTemplate.class); users=mock(AppUserRepository.class); service=new TaskPinService(jdbc,users);
  var user=new AppUser(); user.setId(userId);
  when(users.findByEmail("a@example.com")).thenReturn(Optional.of(user));
 }
 @Test void pinBindsAuthenticatedUserAndTask() {
  when(jdbc.update(anyString(),eq(userId),eq(taskId),eq(userId),eq(userId))).thenReturn(1);
  service.pin("a@example.com",taskId);
  verify(jdbc).update(contains("ON CONFLICT (user_id, task_id)"),eq(userId),eq(taskId),eq(userId),eq(userId));
 }
 @Test void deniedOrMissingTaskReturns404() {
  assertEquals(404,assertThrows(ResponseStatusException.class,()->service.pin("a@example.com",taskId)).getStatusCode().value());
 }
 @Test void missingUserCannotPin() {
  assertEquals(401,assertThrows(ResponseStatusException.class,()->service.pin("unknown",taskId)).getStatusCode().value()); verifyNoInteractions(jdbc);
 }
 @Test void unpinOnlyDeletesCurrentUsersBookmark() {
  service.unpin("a@example.com",taskId);
  verify(jdbc).update("DELETE FROM task_pins WHERE user_id = ? AND task_id = ?",userId,taskId);
 }
 @Test void repeatedUnpinIsSuccessful() {
  assertDoesNotThrow(()->service.unpin("a@example.com",taskId));
  assertDoesNotThrow(()->service.unpin("a@example.com",taskId));
 }
 @Test void listScopesOwnerAndMembershipToCurrentUser() {
  service.list("a@example.com");
  verify(jdbc).query(contains("WHERE pin.user_id = ?"), any(RowMapper.class), eq(userId),eq(userId),eq(userId));
 }
 @Test void secondAccountUsesItsOwnId() {
  var other=new AppUser(); other.setId(UUID.randomUUID());
  when(users.findByEmail("b@example.com")).thenReturn(Optional.of(other));
  service.unpin("b@example.com",taskId);
  verify(jdbc).update(anyString(),eq(other.getId()),eq(taskId));
 }
 @Test void missingUserCannotListOrUnpin() {
  assertThrows(ResponseStatusException.class,()->service.list("unknown"));
  assertThrows(ResponseStatusException.class,()->service.unpin("unknown",taskId)); verifyNoInteractions(jdbc);
 }
}
