-- Migration: Add image_url field to workspaces, projects, and tasks tables
-- Date: 2026-03-24
-- Reason: Support image upload using Cloudinary for workspace, project, and task

-- Add image_url column to workspaces table
ALTER TABLE workspaces
ADD COLUMN image_url TEXT;

-- Add image_url column to projects table
ALTER TABLE projects
ADD COLUMN image_url TEXT;

-- Add image_url column to tasks table
ALTER TABLE tasks
ADD COLUMN image_url TEXT;

-- Create index for faster queries (optional but recommended)
CREATE INDEX idx_workspaces_image_url ON workspaces(image_url);
CREATE INDEX idx_projects_image_url ON projects(image_url);
CREATE INDEX idx_tasks_image_url ON tasks(image_url);
