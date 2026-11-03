package com.example.prm_smart_task.feature.label;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import java.util.*;
import com.example.prm_smart_task.feature.project.entity.Project;
import com.example.prm_smart_task.feature.project.repository.ProjectRepository;
import com.example.prm_smart_task.feature.task.entity.Label;
import com.example.prm_smart_task.feature.task.repository.LabelRepository;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.workspace.entity.*;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import org.springframework.web.server.ResponseStatusException;
class LabelServiceTest {
 ProjectRepository projects; LabelRepository labels; AppUserRepository users; WorkspaceMemberRepository members;
 LabelService service; Project project; AppUser user; Label label; Workspace workspace;
 @BeforeEach void setup() {
  projects=mock(ProjectRepository.class); labels=mock(LabelRepository.class); users=mock(AppUserRepository.class); members=mock(WorkspaceMemberRepository.class);
  service=new LabelService(projects,labels,users,members);
  user=new AppUser(); user.setId(UUID.randomUUID()); user.setFullName("Tester");
  workspace=new Workspace(); workspace.setId(UUID.randomUUID()); workspace.setOwner(user);
  project=new Project(); project.setId(UUID.randomUUID()); project.setWorkspace(workspace);
  label=new Label(); label.setId(UUID.randomUUID()); label.setProject(project); label.setName("Bug"); label.setCreatedBy(user);
  when(projects.findById(project.getId())).thenReturn(Optional.of(project));
  when(users.findByEmail("test@example.com")).thenReturn(Optional.of(user));
  when(labels.findById(label.getId())).thenReturn(Optional.of(label));
  when(labels.findByProjectId(project.getId())).thenReturn(List.of(label));
  when(labels.save(any())).thenAnswer(i->i.getArgument(0));
 }
 @Test void ownerCreatesNormalizedLabel() {
  var result=service.create("test@example.com",project.getId(),new LabelRequest(" Frontend ","#aabbcc"));
  assertEquals("Frontend",result.name()); assertEquals("#AABBCC",result.color()); assertEquals(user.getId(),result.createdById());
 }
 @Test void renameAndRecolorExistingLabel() {
  var result=service.update("test@example.com",project.getId(),label.getId(),new LabelRequest("Backend","#112233"));
  assertEquals(label.getId(),result.id()); assertEquals("Backend",result.name()); assertEquals("#112233",result.color());
 }
 @Test void ownNameIsAllowed() { assertDoesNotThrow(()->service.update("test@example.com",project.getId(),label.getId(),new LabelRequest("Bug","#112233"))); }
 @Test void duplicateIgnoringCaseRejected() { assertThrows(BadRequestException.class,()->service.create("test@example.com",project.getId(),new LabelRequest(" bug ","#112233"))); verify(labels,never()).save(any()); }
 @Test void blankNameRejected() { assertThrows(BadRequestException.class,()->service.create("test@example.com",project.getId(),new LabelRequest("  ","#112233"))); }
 @Test void invalidColorRejected() { assertThrows(BadRequestException.class,()->service.create("test@example.com",project.getId(),new LabelRequest("Frontend","red"))); }
 @Test void longNameRejected() { assertThrows(BadRequestException.class,()->service.create("test@example.com",project.getId(),new LabelRequest("a".repeat(101),"#112233"))); }
 @Test void deletingDetachesBeforeDeletingLabel() {
  service.delete("test@example.com",project.getId(),label.getId());
  var order=inOrder(labels); order.verify(labels).detachFromTasks(label.getId()); order.verify(labels).delete(label);
 }
 @Test void crossProjectDeleteRejectedWithoutMutation() {
  var other=new Project(); other.setId(UUID.randomUUID()); label.setProject(other);
  assertThrows(BadRequestException.class,()->service.delete("test@example.com",project.getId(),label.getId()));
  verify(labels,never()).detachFromTasks(any()); verify(labels,never()).delete(any());
 }
 void member(String role,String status) {
  var owner=new AppUser(); owner.setId(UUID.randomUUID()); workspace.setOwner(owner);
  var member=new WorkspaceMember(); member.setRole(role); member.setInvitationStatus(status);
  when(members.findByWorkspaceIdAndUserId(workspace.getId(),user.getId())).thenReturn(Optional.of(member));
 }
 @Test void acceptedAdminAllowed() { member("admin","accepted"); assertDoesNotThrow(()->service.create("test@example.com",project.getId(),new LabelRequest("Frontend","#112233"))); }
 @Test void pendingAdminDenied() { member("admin","pending"); assertEquals(403,assertThrows(ResponseStatusException.class,()->service.delete("test@example.com",project.getId(),label.getId())).getStatusCode().value()); verifyNoInteractions(labels); }
 @Test void ordinaryMemberDenied() { member("member","accepted"); assertThrows(ResponseStatusException.class,()->service.update("test@example.com",project.getId(),label.getId(),new LabelRequest("Frontend","#112233"))); verifyNoInteractions(labels); }
}
