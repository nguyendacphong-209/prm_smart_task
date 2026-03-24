package com.example.prm_smart_task.feature.collaboration.service;

import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.prm_smart_task.dto.collaboration.AttachmentResponse;
import com.example.prm_smart_task.dto.collaboration.CommentResponse;
import com.example.prm_smart_task.dto.collaboration.CreateCommentRequest;
import com.example.prm_smart_task.feature.user.entity.AppUser;
import com.example.prm_smart_task.feature.task.entity.Attachment;
import com.example.prm_smart_task.entity.Comment;
import com.example.prm_smart_task.feature.task.entity.Task;
import com.example.prm_smart_task.feature.shared.exception.BadRequestException;
import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;
import com.example.prm_smart_task.feature.task.repository.AttachmentRepository;
import com.example.prm_smart_task.repository.CommentRepository;
import com.example.prm_smart_task.feature.task.repository.TaskRepository;
import com.example.prm_smart_task.feature.workspace.repository.WorkspaceMemberRepository;

@Service
public class CollaborationService {

    private static final Pattern MENTION_PATTERN = Pattern.compile("@([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,})");

    private final CommentRepository commentRepository;
    private final AttachmentRepository attachmentRepository;
    private final TaskRepository taskRepository;
    private final AppUserRepository appUserRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public CollaborationService(
            CommentRepository commentRepository,
            AttachmentRepository attachmentRepository,
            TaskRepository taskRepository,
            AppUserRepository appUserRepository,
            WorkspaceMemberRepository workspaceMemberRepository) {
        this.commentRepository = commentRepository;
        this.attachmentRepository = attachmentRepository;
        this.taskRepository = taskRepository;
        this.appUserRepository = appUserRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @Transactional
    public CommentResponse addComment(String currentEmail, UUID taskId, CreateCommentRequest request) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        Comment comment = new Comment();
        comment.setTask(task);
        comment.setUser(currentUser);
        comment.setContent(request.content().trim());

        Comment savedComment = commentRepository.save(comment);
        return mapComment(savedComment);
    }

    @Transactional(readOnly = true)
    public List<CommentResponse> getCommentsByTask(String currentEmail, UUID taskId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        return commentRepository.findByTaskIdOrderByCreatedAtAsc(taskId)
                .stream()
                .map(this::mapComment)
                .toList();
    }

    @Transactional
    public AttachmentResponse uploadAttachmentMock(String currentEmail, UUID taskId, MultipartFile file) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Attachment file is required");
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.isBlank()) {
            throw new BadRequestException("File name is invalid");
        }

        String sanitizedFileName = originalFilename.replaceAll("[^A-Za-z0-9._-]", "_");
        String fakeUrl = "/mock-storage/attachments/" + UUID.randomUUID() + "-" + sanitizedFileName;

        Attachment attachment = new Attachment();
        attachment.setTask(task);
        attachment.setFileName(sanitizedFileName);
        attachment.setFileUrl(fakeUrl);

        Attachment savedAttachment = attachmentRepository.save(attachment);
        return mapAttachment(savedAttachment);
    }

    @Transactional(readOnly = true)
    public List<AttachmentResponse> getAttachmentsByTask(String currentEmail, UUID taskId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Task task = getTask(taskId);
        ensureWorkspaceMember(currentUser, task.getProject().getWorkspace().getId());

        return attachmentRepository.findByTaskIdOrderByUploadedAtDesc(taskId)
                .stream()
                .map(this::mapAttachment)
                .toList();
    }

    private AppUser getUserByEmail(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        return appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private Task getTask(UUID taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new BadRequestException("Task not found"));
    }

    private void ensureWorkspaceMember(AppUser currentUser, UUID workspaceId) {
        boolean isMember = workspaceMemberRepository.existsByWorkspaceIdAndUserId(workspaceId, currentUser.getId());
        if (!isMember) {
            throw new UnauthorizedException("You are not a member of this workspace");
        }
    }

    private CommentResponse mapComment(Comment comment) {
        return new CommentResponse(
                comment.getId(),
                comment.getTask().getId(),
                comment.getUser().getId(),
                comment.getUser().getEmail(),
                comment.getUser().getFullName(),
                comment.getContent(),
                extractMentions(comment.getContent()),
                comment.getCreatedAt());
    }

    private AttachmentResponse mapAttachment(Attachment attachment) {
        return new AttachmentResponse(
                attachment.getId(),
                attachment.getTask().getId(),
                attachment.getFileName(),
                attachment.getFileUrl(),
                attachment.getUploadedAt());
    }

    private List<String> extractMentions(String content) {
        Matcher matcher = MENTION_PATTERN.matcher(content == null ? "" : content);
        List<String> mentions = new java.util.ArrayList<>();
        while (matcher.find()) {
            mentions.add(matcher.group(1).toLowerCase());
        }
        return mentions.stream().distinct().toList();
    }
}
