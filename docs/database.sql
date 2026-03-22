-- USERS
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- WORKSPACE
CREATE TABLE workspaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- WORKSPACE MEMBERS
CREATE TABLE workspace_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    invited_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    role VARCHAR(50) DEFAULT 'member',
    invitation_status VARCHAR(50) DEFAULT 'accepted',
    UNIQUE (workspace_id, user_id)
);

-- PROJECT
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TASK STATUS (KANBAN COLUMN)
CREATE TABLE task_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    position INT NOT NULL
);

-- TASK
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    status_id UUID REFERENCES task_statuses(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20),
    deadline TIMESTAMP,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TASK ASSIGNMENT (multi assign)
CREATE TABLE task_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (task_id, user_id)
);

-- LABEL
CREATE TABLE labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100),
    color VARCHAR(20)
);

-- TASK LABEL (many-to-many)
CREATE TABLE task_labels (
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    label_id UUID REFERENCES labels(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, label_id)
);

-- COMMENT
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ATTACHMENT
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    file_url TEXT,
    file_name VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NOTIFICATION
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50),
    content TEXT,
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MIGRATION: Add created_by column to labels table
ALTER TABLE labels ADD COLUMN created_by UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE workspace_members
ADD COLUMN invitation_status VARCHAR(50) NOT NULL DEFAULT 'accepted';

ALTER TABLE workspace_members
ADD COLUMN invited_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE notifications
ADD COLUMN workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE;

ALTER TABLE notifications
ADD COLUMN target_user_id UUID REFERENCES users(id) ON DELETE SET NULL;