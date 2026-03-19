# Copilot Instructions - Smart Task Manager

## 📌 Project Overview

This is a Smart Task Manager application similar to Trello/Notion (small to medium scale).

Tech stack:

- Frontend: Flutter (Riverpod, Dio, GoRouter)
- Backend: Spring Boot (Java)
- Database: PostgreSQL

---

## 🧠 General Rules

- Write clean, readable, maintainable code
- Follow SOLID principles
- Avoid duplicate code
- Use meaningful variable and function names
- Prefer composition over inheritance
- Keep code modular and scalable

---

## 🏗 Architecture

### Backend (Spring Boot)

Use layered architecture:

- controller → handle HTTP request/response
- service → business logic
- repository → data access (JPA)

Do NOT:

- Put business logic inside controller
- Expose entity directly to client

---

### Frontend (Flutter)

Use feature-based structure:

- presentation (UI)
- application (state management)
- domain (models)
- data (API, repository)

Do NOT:

- Call API directly inside UI
- Mix UI with business logic

---

## ☕ Spring Boot Rules

### Structure

- Use packages:
  - controller
  - service
  - repository
  - entity
  - dto
  - exception
  - config
  - security

---

### Entity Rules

- Use JPA annotations
- Use UUID as primary key
- Include:
  - id
  - createdAt
  - updatedAt

- Relationships:
  - Workspace → Project → Task
  - Task → User (assignee)
  - Task → Comment

---

### DTO Rules

- Always use DTO for request/response
- Do NOT return entity directly
- Use validation annotations:
  - @NotNull
  - @Email
  - @Size

---

### Repository Rules

- Use Spring Data JPA (JpaRepository)
- Do not write unnecessary queries if JPA can handle it

---

### Service Rules

- Business logic must be inside service
- Use @Transactional where needed

---

### Controller Rules

- Use @RestController
- Use RESTful API conventions:

Examples:

- GET /tasks
- POST /tasks
- PUT /tasks/{id}
- DELETE /tasks/{id}

- Return ResponseEntity

---

### Exception Handling

- Use @ControllerAdvice
- Create custom exceptions
- Return meaningful error messages

---

### Security

- Use Spring Security
- Use JWT authentication
- Hash password (BCrypt)

---

## 🗄 Database Rules (PostgreSQL)

Tables must include:

- id (UUID)
- created_at
- updated_at

Naming convention:

- snake_case for database
- camelCase for Java

---

## 📱 Flutter Rules

### State Management

- Use Riverpod only
- Do not use setState for business logic

---

### Networking

- Use Dio for API calls
- Centralize API logic

---

### UI

- Create reusable widgets
- Keep UI clean and separated

---

## 🔗 API Rules

- All API calls go through service/repository layer
- Handle errors properly (try/catch)
- Use consistent response format

---

## 📦 Naming Convention

- Class: PascalCase
- Variable: camelCase
- Database: snake_case

---

## 🧪 Code Generation Rules

When generating code:

- Always include full working code (not partial)
- Include imports
- Follow project structure
- Ensure code compiles
- Add basic comments if needed

---

## 🎯 Output Expectation

- Code must be production-ready
- Follow best practices
- Be consistent across files
- Avoid unnecessary complexity

---

## 📖 Reference

Use requirements from:

- /docs/requirements.md

## Database Reference

- Use schema from /docs/database.sql
