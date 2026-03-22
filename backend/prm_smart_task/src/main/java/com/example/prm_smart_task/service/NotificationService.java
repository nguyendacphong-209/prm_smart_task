package com.example.prm_smart_task.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.prm_smart_task.dto.common.ApiMessageResponse;
import com.example.prm_smart_task.dto.notification.NotificationResponse;
import com.example.prm_smart_task.dto.notification.UnreadCountResponse;
import com.example.prm_smart_task.entity.AppUser;
import com.example.prm_smart_task.entity.Notification;
import com.example.prm_smart_task.entity.Task;
import com.example.prm_smart_task.entity.Workspace;
import com.example.prm_smart_task.exception.BadRequestException;
import com.example.prm_smart_task.exception.UnauthorizedException;
import com.example.prm_smart_task.repository.AppUserRepository;
import com.example.prm_smart_task.repository.NotificationRepository;

@Service
public class NotificationService {

    public static final String TYPE_TASK_ASSIGNED = "TASK_ASSIGNED";
    public static final String TYPE_TASK_STATUS_CHANGED = "TASK_STATUS_CHANGED";
    public static final String TYPE_WORKSPACE_INVITED = "WORKSPACE_INVITED";
    public static final String TYPE_WORKSPACE_INVITE_APPROVAL_REQUEST = "WORKSPACE_INVITE_APPROVAL_REQUEST";
    public static final String TYPE_WORKSPACE_INVITATION_APPROVED = "WORKSPACE_INVITATION_APPROVED";
    public static final String TYPE_WORKSPACE_INVITATION_REJECTED = "WORKSPACE_INVITATION_REJECTED";

    private final NotificationRepository notificationRepository;
    private final AppUserRepository appUserRepository;

    public NotificationService(NotificationRepository notificationRepository, AppUserRepository appUserRepository) {
        this.notificationRepository = notificationRepository;
        this.appUserRepository = appUserRepository;
    }

    @Transactional(readOnly = true)
    public List<NotificationResponse> getMyNotifications(String currentEmail) {
        AppUser currentUser = getUserByEmail(currentEmail);
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(this::mapNotification)
                .toList();
    }

    @Transactional(readOnly = true)
    public UnreadCountResponse getUnreadCount(String currentEmail) {
        AppUser currentUser = getUserByEmail(currentEmail);
        long unreadCount = notificationRepository.countByUserIdAndIsReadFalse(currentUser.getId());
        return new UnreadCountResponse(unreadCount);
    }

    @Transactional
    public NotificationResponse markAsRead(String currentEmail, UUID notificationId) {
        AppUser currentUser = getUserByEmail(currentEmail);
        Notification notification = notificationRepository.findByIdAndUserId(notificationId, currentUser.getId())
                .orElseThrow(() -> new BadRequestException("Notification not found"));

        if (!notification.isRead()) {
            notification.setRead(true);
            notification = notificationRepository.save(notification);
        }

        return mapNotification(notification);
    }

    @Transactional
    public ApiMessageResponse markAllAsRead(String currentEmail) {
        AppUser currentUser = getUserByEmail(currentEmail);
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId());

        for (Notification notification : notifications) {
            if (!notification.isRead()) {
                notification.setRead(true);
            }
        }

        notificationRepository.saveAll(notifications);
        return new ApiMessageResponse("All notifications marked as read");
    }

    @Transactional
    public void notifyTaskAssigned(AppUser recipient, Task task, AppUser assignedBy) {
        if (recipient.getId().equals(assignedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(recipient);
        notification.setType(TYPE_TASK_ASSIGNED);
        notification.setRead(false);
        notification.setContent("You were assigned to task: " + task.getTitle());
        notificationRepository.save(notification);
    }

    @Transactional
    public void notifyTaskStatusChanged(AppUser recipient, Task task, String oldStatusName, String newStatusName, AppUser changedBy) {
        if (recipient.getId().equals(changedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(recipient);
        notification.setType(TYPE_TASK_STATUS_CHANGED);
        notification.setRead(false);
        notification.setContent("Task '" + task.getTitle() + "' status changed from '" + oldStatusName + "' to '" + newStatusName + "'");
        notificationRepository.save(notification);
    }

    @Transactional
    public void notifyWorkspaceInvited(AppUser recipient, Workspace workspace, AppUser invitedBy, boolean directJoin) {
        if (recipient.getId().equals(invitedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(recipient);
        notification.setType(TYPE_WORKSPACE_INVITED);
        notification.setRead(false);
        notification.setWorkspaceId(workspace.getId());
        notification.setTargetUserId(recipient.getId());
        notification.setContent(directJoin
                ? "You were added to workspace '" + workspace.getName() + "' by " + invitedBy.getFullName()
                : "You were invited to workspace '" + workspace.getName() + "' by " + invitedBy.getFullName()
                        + ". Waiting for owner approval.");
        notificationRepository.save(notification);
    }

    @Transactional
    public void notifyWorkspaceInviteApprovalRequired(
            AppUser owner,
            Workspace workspace,
            AppUser invitedUser,
            AppUser invitedBy) {
        if (owner.getId().equals(invitedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(owner);
        notification.setType(TYPE_WORKSPACE_INVITE_APPROVAL_REQUEST);
        notification.setRead(false);
        notification.setWorkspaceId(workspace.getId());
        notification.setTargetUserId(invitedUser.getId());
        notification.setContent("" + invitedBy.getFullName() + " invited " + invitedUser.getEmail()
                + " to workspace '" + workspace.getName() + "'. Please approve.");
        notificationRepository.save(notification);
    }

    @Transactional
    public void notifyWorkspaceInvitationApproved(AppUser recipient, Workspace workspace, AppUser approvedBy) {
        if (recipient.getId().equals(approvedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(recipient);
        notification.setType(TYPE_WORKSPACE_INVITATION_APPROVED);
        notification.setRead(false);
        notification.setWorkspaceId(workspace.getId());
        notification.setTargetUserId(recipient.getId());
        notification.setContent("Your invitation to workspace '" + workspace.getName() + "' was approved by "
                + approvedBy.getFullName());
        notificationRepository.save(notification);
    }

    @Transactional
    public void notifyWorkspaceInvitationRejected(AppUser adminRequester, Workspace workspace, AppUser rejectedBy) {
        if (adminRequester.getId().equals(rejectedBy.getId())) {
            return;
        }

        Notification notification = new Notification();
        notification.setUser(adminRequester);
        notification.setType(TYPE_WORKSPACE_INVITATION_REJECTED);
        notification.setRead(false);
        notification.setWorkspaceId(workspace.getId());
        notification.setContent("Owner " + rejectedBy.getFullName()
                + " rejected your invite request in workspace '" + workspace.getName() + "'.");
        notificationRepository.save(notification);
    }

    private AppUser getUserByEmail(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        return appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private NotificationResponse mapNotification(Notification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getType(),
                notification.getContent(),
                notification.isRead(),
            notification.getWorkspaceId(),
            notification.getTargetUserId(),
                notification.getCreatedAt());
    }
}
