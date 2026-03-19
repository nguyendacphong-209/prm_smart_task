# UIIU Requirement - Smart Task Manager

## 1. Mục tiêu UI
- Xây dựng giao diện mobile hiện đại theo phong cách **Liquid Glass** (iPhone-like).
- Hỗ trợ đầy đủ **Light Mode** và **Dark Mode**.
- Tối ưu cho thao tác nhanh: tạo task, kéo thả Kanban, comment, theo dõi dashboard.

## 2. Design Style (Liquid Glass)
- Nền sử dụng gradient mềm, tone lạnh (blue/indigo) cho cảm giác trong suốt.
- Các khối chính (card/panel/dialog) dùng hiệu ứng:
  - Blur nền (glass effect)
  - Border mờ sáng
  - Shadow nhẹ, bo góc lớn (18-24)
- Hạn chế đường viền cứng và màu quá gắt.
- Dùng icon đơn giản, dễ nhìn trong cả light/dark mode.

## 3. Theme Requirement
- Bắt buộc có 2 theme:
  - `Light Theme`
  - `Dark Theme`
- Mặc định `ThemeMode.system` (theo hệ điều hành).
- Cần có khả năng thêm nút manual switch theme ở phần Settings (phase sau).
- Màu chữ/độ tương phản đạt mức dễ đọc ở cả 2 mode.

## 4. Màn hình bắt buộc (theo feature)
### 4.1 Authentication
- Login
- Register
- Profile (view/update)
- Change password

### 4.2 Workspace
- Workspace list
- Create workspace
- Workspace detail
- Member management (invite, role update, remove)

### 4.3 Project
- Project list theo workspace
- Create project
- Update/Delete project

### 4.4 Task
- Task list theo project
- Create task
- Task detail/edit
- Assign member, deadline, priority, label

### 4.5 Kanban
- Board view theo cột status
- Drag & drop task card giữa các status
- Create new status

### 4.6 Collaboration
- Comment list trong task
- Add comment
- Mention user theo email
- Upload attachment (mock hiện tại)

### 4.7 Notification
- Notification list
- Unread badge count
- Mark read / Mark all read

### 4.8 Dashboard
- My Dashboard (assigned/completed/overdue/due soon)
- Project Dashboard (completion %, tasks by status/priority)

## 5. Navigation Requirement
- Dùng `GoRouter` với cấu trúc route rõ ràng:
  - `/login`, `/register`
  - `/workspaces`
  - `/workspaces/:id/projects`
  - `/projects/:id/kanban`
  - `/tasks/:id`
  - `/notifications`
  - `/dashboard`
- Có guard route cho các màn hình cần đăng nhập.
- Có deep-link structure sẵn cho phase sau.

## 6. State & Data Requirement
- State management dùng `Riverpod`.
- API client dùng `Dio` + interceptor cho JWT access token.
- Lưu token local bằng `SharedPreferences` (hoặc secure storage ở phase nâng cao).
- Mỗi màn hình phải có đủ 4 trạng thái:
  - Loading
  - Success
  - Empty
  - Error (kèm retry)

## 7. Component Requirement
Các reusable component tối thiểu:
- GlassCard
- PrimaryButton / SecondaryButton
- AppTextField
- AppScaffold (background + appbar chuẩn)
- LoadingView
- EmptyStateView
- ErrorStateView
- StatusChip (priority/status)
- NotificationBadge

## 8. UX Requirement
- Tốc độ phản hồi thao tác chính < 300ms cho chuyển trạng thái UI nội bộ.
- Khi gọi API phải có feedback rõ (loading indicator/skeleton).
- Hành động nguy hiểm (delete/remove) cần confirm dialog.
- Form bắt buộc validate ngay trên UI (email format, password length, required fields).
- Kanban drag/drop cần animation mượt và có phản hồi trực quan.

## 9. Accessibility Requirement
- Font size tối thiểu 14 cho nội dung thường.
- Tap target tối thiểu 44x44.
- Không dùng màu làm tín hiệu duy nhất (kết hợp icon/text).
- Hỗ trợ dark mode không làm giảm khả năng đọc.

## 10. Responsive Requirement
- Ưu tiên mobile dọc (portrait).
- Hỗ trợ màn hình nhỏ (<= 360 width) không vỡ layout.
- Tablet sẽ follow sau, nhưng layout phải tách component để mở rộng dễ.

## 11. Ưu tiên triển khai (MVP)
Phase 1:
- Auth + Workspace list + Project list + Task list + Kanban basic

Phase 2:
- Collaboration + Notification + Dashboard

Phase 3:
- Polish UI, animation, theme switch thủ công, nâng cấp accessibility

## 12. Definition of Done (UI)
- Mỗi feature có màn hình chính + trạng thái loading/empty/error.
- Theme light/dark hiển thị đúng, không lỗi contrast.
- Reusable components dùng thống nhất toàn app.
- Điều hướng bằng GoRouter hoạt động đúng theo role/auth state.
- Match API contract trong `docs/api_endpoints.md`.
