CREATE TABLE IF NOT EXISTS task_activities (
 id UUID PRIMARY KEY,
 task_id UUID NOT NULL,
 actor_id UUID NOT NULL,
 actor_name VARCHAR(255) NOT NULL,
 field VARCHAR(255) NOT NULL,
 old_value TEXT,
 new_value TEXT,
 created_at TIMESTAMP WITH TIME ZONE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_task_activities_task_time ON task_activities(task_id, created_at DESC, id DESC);
