# prm_smart_task

# 🚀 Smart Task Manager

## 📌 Overview

Smart Task Manager is a mobile application designed to help users manage tasks, projects, and team collaboration efficiently.  
The system is inspired by tools like Trello and Notion, focusing on small to medium teams.

---

## 🎯 Objectives

- Help users organize tasks effectively
- Improve team collaboration
- Track project progress visually using Kanban board

---

## ✨ Features

### 🔐 Authentication

- Register / Login
- JWT-based authentication

### 🏢 Workspace Management

- Create workspace
- Invite members
- Manage team members

### 📁 Project Management

- Create / update / delete project
- View project list

### ✅ Task Management

- Create / edit / delete task
- Assign task to users
- Set deadline, priority, label

### 📊 Kanban Board

- Drag & drop tasks between statuses
- Custom task statuses

### 💬 Collaboration

- Comment on tasks
- Mention users
- Attach files

### 🔔 Notification

- Task assignment notifications
- Status change notifications

### 📈 Dashboard

- Task statistics
- Project progress tracking

---

## 👥 Target Users

- Students working on group projects
- Small development teams
- Freelancers
- Individuals managing personal tasks

---

## 🛠 Tech Stack

### 📱 Frontend

- Flutter
- Riverpod
- Dio
- GoRouter

### ⚙️ Backend

- Spring Boot
- Spring Security
- JPA / Hibernate

### 🗄 Database

- PostgreSQL
## 📊 Database Schema

Database schema is defined in:
/docs/database.sql
---

## 🧱 System Architecture

## ⚙️ Backend Environment Setup

Backend config uses environment variables defined in:
[backend/prm_smart_task/src/main/resources/application.properties](backend/prm_smart_task/src/main/resources/application.properties)

### 🖥️ Local Development Setup

1. **Create .env file from template:**
   ```bash
   cp backend/prm_smart_task/.env.example backend/prm_smart_task/.env
   ```

2. **Update .env with your local database credentials:**
   ```env
   PORT=8080
   DB_URL=jdbc:postgresql://localhost:5432/prm_smart_task?sslmode=disable
   DB_USERNAME=postgres
   DB_PASSWORD=postgres
   JWT_SECRET=your-local-secret-key-min-32-chars
   JWT_EXPIRATION_MS=86400000
   JWT_REFRESH_EXPIRATION_MS=604800000
   JPA_DDL_AUTO=update
   JPA_SHOW_SQL=false
   ```

3. **Export environment variables and run:**
   ```bash
   cd backend/prm_smart_task
   set -a
   source .env
   set +a
   ./gradlew bootRun
   ```

⚠️ **Security Note:** Never commit `.env` file or `application-local.properties` - they contain sensitive credentials.

### ☁️ Render Deployment Setup

In your Render service dashboard (Web Service), add these environment variables:

| Variable | Value | Notes |
|----------|-------|-------|
| `PORT` | `10000` | Render uses this port |
| `DB_URL` | `jdbc:postgresql://your-host:5432/your-db?sslmode=require` | From Render PostgreSQL addon |
| `DB_USERNAME` | `your-postgres-user` | From Render PostgreSQL addon |
| `DB_PASSWORD` | `your-postgres-password` | From Render PostgreSQL addon - KEEP SECURE |
| `JWT_SECRET` | Strong random string (min 32 chars) | Generate strong random key |
| `JWT_EXPIRATION_MS` | `86400000` | 24 hours in milliseconds |
| `JWT_REFRESH_EXPIRATION_MS` | `604800000` | 7 days in milliseconds |
| `JPA_DDL_AUTO` | `validate` | Use `validate` in production (not `update`) |
| `JPA_SHOW_SQL` | `false` | Disable SQL logging in production |

**Build Command (in Render):**
```bash
cd backend/prm_smart_task && ./gradlew bootJar
```

**Start Command (in Render):**
```bash
cd backend/prm_smart_task && java -jar build/libs/prm_smart_task-*.jar
```

### 🧪 Testing API Endpoints
We will follow prm_smart_task/test_api to testing api

Email support: dacphong2092003@gmail.com (Contact me)
