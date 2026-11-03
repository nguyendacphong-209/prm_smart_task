package com.example.prm_smart_task.feature.activity;
import org.junit.jupiter.api.*;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;
import java.util.*;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.data.domain.*;
import com.example.prm_smart_task.feature.task.repository.TaskRepository;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.feature.task.entity.Task;
import com.example.prm_smart_task.feature.project.entity.Project;
import com.example.prm_smart_task.feature.workspace.entity.Workspace;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.shared.exception.*;
class TaskActivityControllerTest {
 TaskActivityRepository activities=mock(TaskActivityRepository.class);
 TaskRepository tasks=mock(TaskRepository.class);
 AppUserRepository users=mock(AppUserRepository.class);
 WorkspaceMemberRepository members=mock(WorkspaceMemberRepository.class);
 TaskActivityController controller=new TaskActivityController(activities,tasks,users,members);
 UUID taskId=UUID.randomUUID(), userId=UUID.randomUUID(), workspaceId=UUID.randomUUID();
 UsernamePasswordAuthenticationToken auth=new UsernamePasswordAuthenticationToken("a@example.com","unused");
 @BeforeEach void setup() {
  var user=new AppUser(); user.setId(userId); when(users.findByEmail(auth.getName())).thenReturn(Optional.of(user));
  var workspace=new Workspace(); workspace.setId(workspaceId);
  var project=new Project(); project.setWorkspace(workspace);
  var task=new Task(); task.setId(taskId); task.setProject(project); when(tasks.findById(taskId)).thenReturn(Optional.of(task));
 }
 @Test void outsiderCannotReadHistory() {
  assertThrows(UnauthorizedException.class,()->controller.list(auth,taskId,0)); verifyNoInteractions(activities);
 }
 @Test void missingTaskIsRejected() {
  when(tasks.findById(taskId)).thenReturn(Optional.empty()); assertThrows(BadRequestException.class,()->controller.list(auth,taskId,0)); verifyNoInteractions(activities);
 }
 @Test void memberReadsBoundedPage() {
  when(members.existsByWorkspaceIdAndUserId(workspaceId,userId)).thenReturn(true);
  when(activities.findByTaskIdOrderByCreatedAtDescIdDesc(taskId,PageRequest.of(1,20))).thenReturn(Page.empty());
  assertTrue(controller.list(auth,taskId,1).isEmpty()); verify(activities).findByTaskIdOrderByCreatedAtDescIdDesc(taskId,PageRequest.of(1,20));
 }
 @Test void negativePageRejected() {
  when(members.existsByWorkspaceIdAndUserId(workspaceId,userId)).thenReturn(true);
  assertThrows(BadRequestException.class,()->controller.list(auth,taskId,-1)); verifyNoInteractions(activities);
 }
}
