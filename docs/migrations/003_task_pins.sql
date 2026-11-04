-- Personal task bookmarks. Run before deploying the pin API.
BEGIN;
CREATE TABLE IF NOT EXISTS task_pins (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    pinned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, task_id)
);
CREATE INDEX IF NOT EXISTS idx_task_pins_user_time ON task_pins(user_id, pinned_at DESC, task_id);
CREATE INDEX IF NOT EXISTS idx_task_pins_task ON task_pins(task_id);
COMMIT;
