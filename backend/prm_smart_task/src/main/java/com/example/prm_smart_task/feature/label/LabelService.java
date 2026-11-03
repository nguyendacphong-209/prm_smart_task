package com.example.prm_smart_task.feature.label;

import java.util.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import com.example.prm_smart_task.dto.task.TaskLabelResponse;
import com.example.prm_smart_task.feature.project.entity.Project;
import com.example.prm_smart_task.feature.project.repository.ProjectRepository;
import com.example.prm_smart_task.feature.task.entity.Label;
import com.example.prm_smart_task.feature.task.repository.LabelRepository;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;

@Service
@Transactional
public class LabelService {
 private final ProjectRepository projects;
 private final LabelRepository labels;
 private final AppUserRepository users;
 private final WorkspaceMemberRepository members;
 public LabelService(ProjectRepository projects, LabelRepository labels, AppUserRepository users, WorkspaceMemberRepository members) {
  this.projects=projects; this.labels=labels; this.users=users; this.members=members;
 }
 private AppUser manager(String email, Project project) {
  var user=users.findByEmail(email).orElseThrow(()->new ResponseStatusException(HttpStatus.UNAUTHORIZED));
  var workspace=project.getWorkspace();
  if(workspace.getOwner().getId().equals(user.getId())) return user;
  var member=members.findByWorkspaceIdAndUserId(workspace.getId(),user.getId());
  if(member.isEmpty() || !"accepted".equalsIgnoreCase(member.get().getInvitationStatus()) || !"admin".equalsIgnoreCase(member.get().getRole()))
   throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Chỉ chủ workspace hoặc admin được quản lý nhãn");
  return user;
 }
 private Project project(UUID id) {
  return projects.findById(id).orElseThrow(()->new BadRequestException("Project not found"));
 }
 private Label label(UUID projectId, UUID id) {
  return labels.findById(id).filter(l->l.getProject().getId().equals(projectId))
   .orElseThrow(()->new BadRequestException("Label not found in this project"));
 }
 private void values(Label label, LabelRequest request) {
  var name=request.name()==null ? "" : request.name().trim();
  if(name.isEmpty() || name.length()>100) throw new BadRequestException("Tên nhãn phải có từ 1 đến 100 ký tự");
  if(request.color()==null || !request.color().matches("#[0-9a-fA-F]{6}")) throw new BadRequestException("Màu nhãn không hợp lệ");
  if(labels.findByProjectId(label.getProject().getId()).stream().anyMatch(l-> !Objects.equals(l.getId(),label.getId()) && l.getName()!=null && l.getName().trim().equalsIgnoreCase(name)))
   throw new BadRequestException("Tên nhãn đã tồn tại trong project");
  label.setName(name); label.setColor(request.color().toUpperCase(Locale.ROOT));
 }
 public TaskLabelResponse create(String email, UUID projectId, LabelRequest request) {
  var project=project(projectId); var user=manager(email,project);
  var label=new Label(); label.setProject(project); label.setCreatedBy(user); values(label,request);
  return response(labels.save(label));
 }
 public TaskLabelResponse update(String email, UUID projectId, UUID id, LabelRequest request) {
  manager(email,project(projectId)); var label=label(projectId,id); values(label,request);
  return response(labels.save(label));
 }
 public void delete(String email, UUID projectId, UUID id) {
  manager(email,project(projectId)); var label=label(projectId,id);
  labels.detachFromTasks(id); labels.delete(label);
 }
 private TaskLabelResponse response(Label label) {
  var creator=label.getCreatedBy();
  return new TaskLabelResponse(label.getId(),label.getName(),label.getColor(),creator==null?null:creator.getId(),creator==null?null:creator.getFullName());
 }
}
