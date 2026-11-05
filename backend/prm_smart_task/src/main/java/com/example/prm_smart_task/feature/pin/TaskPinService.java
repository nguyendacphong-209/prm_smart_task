package com.example.prm_smart_task.feature.pin;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import com.example.prm_smart_task.feature.user.repository.AppUserRepository;

@Service
@Transactional
public class TaskPinService {
    private final JdbcTemplate jdbc;
    private final AppUserRepository users;
    public TaskPinService(JdbcTemplate jdbc, AppUserRepository users) {
        this.jdbc = jdbc;
        this.users = users;
    }
    // The same access predicate applies to both listing and creating bookmarks.
    static final String ACCESS = """
        (w.owner_id = ? OR EXISTS (
            SELECT 1 FROM workspace_members m
            WHERE m.workspace_id = w.id AND m.user_id = ?
              AND lower(m.invitation_status) = 'accepted'))
        """;
    private UUID userId(String email) {
        return users.findByEmail(email).orElseThrow(() ->
            new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found")).getId();
    }
    public record PinnedTask(UUID taskId, UUID projectId, UUID workspaceId,
                             String title, String projectName, String priority,
                             LocalDateTime deadline, java.time.Instant pinnedAt) {}
    @Transactional(readOnly = true)
    public List<PinnedTask> list(String email) {
        var user = userId(email);
        return jdbc.query("""
            SELECT t.id, p.id AS project_id, w.id AS workspace_id,
                   t.title, p.name AS project_name, t.priority, t.deadline, pin.pinned_at
            FROM task_pins pin JOIN tasks t ON t.id = pin.task_id
            JOIN projects p ON p.id = t.project_id
            JOIN workspaces w ON w.id = p.workspace_id
            WHERE pin.user_id = ? AND
            """ + ACCESS + " ORDER BY pin.pinned_at DESC, t.id", (rs, row) ->
                new PinnedTask(rs.getObject("id", UUID.class), rs.getObject("project_id", UUID.class),
                    rs.getObject("workspace_id", UUID.class), rs.getString("title"), rs.getString("project_name"),
                    rs.getString("priority"), rs.getObject("deadline", LocalDateTime.class),
                    rs.getTimestamp("pinned_at").toInstant()), user, user, user);
    }
    public void pin(String email, UUID taskId) {
        var user = userId(email);
        int changed = jdbc.update("""
            INSERT INTO task_pins (user_id, task_id)
            SELECT ?, t.id FROM tasks t
            JOIN projects p ON p.id = t.project_id
            JOIN workspaces w ON w.id = p.workspace_id
            WHERE t.id = ? AND
            """ + ACCESS + """
            ON CONFLICT (user_id, task_id) DO UPDATE SET pinned_at = task_pins.pinned_at
            """, user, taskId, user, user);
        if (changed == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Task không tồn tại hoặc bạn không có quyền truy cập");
        }
    }
    public void unpin(String email, UUID taskId) {
        // Allow cleanup of one's own bookmark even after access is revoked.
        jdbc.update("DELETE FROM task_pins WHERE user_id = ? AND task_id = ?", userId(email), taskId);
    }
}
