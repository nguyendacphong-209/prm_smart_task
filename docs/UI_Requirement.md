# UI Requirement - Smart Task Manager (Trello-like + Liquid Glass)

## 1. Mục tiêu UI
- Xây dựng UI mobile theo mô hình thao tác của Trello: board-first, card-first, thao tác nhanh, ít bước.
- Phong cách thị giác bắt buộc: Liquid Glass giống ảnh mẫu (nền mờ, khối nổi trong suốt, bo góc lớn, hiệu ứng mềm).
- Hỗ trợ đầy đủ Light/Dark mode và luôn ưu tiên khả năng đọc.
- Tối ưu cho luồng chính: tạo task nhanh, kéo thả Kanban, mở card xem chi tiết, comment/attachment, theo dõi dashboard.

## 2. Trello-like UX Principles (bắt buộc)

### 2.1 Board-first Navigation
- Từ Project phải truy cập Kanban trong 1 thao tác.
- Task luôn được đại diện bằng card, không hiển thị kiểu danh sách text thuần ở các màn chính.
- Card bấm được toàn bộ vùng (không chỉ icon) để vào task detail.

### 2.2 Card-first Interaction
- Card phải hiển thị tối thiểu: title, status/priority, deadline (nếu có), assignee/avatar (nếu có), nhãn (label) ngắn.
- Action nhanh trên card: edit/delete hoặc open detail (qua menu/gesture, không làm rối UI).
- Cập nhật card xong phải phản ánh ngay trên board/list (optimistic hoặc refresh tức thì).

### 2.3 Progressive Disclosure
- Màn list/board chỉ hiển thị thông tin thiết yếu.
- Chi tiết nâng cao (description dài, comments, attachments, history) đặt ở task detail.
- Không nhồi quá nhiều control vào một card.

### 2.4 Predictable Patterns
- Cùng một hành vi phải dùng cùng một mẫu UI ở toàn app (confirm dialog, empty state, error retry, chip status).
- CTA chính luôn nổi bật, CTA phụ kiểu tonal/outlined.
- Hành động nguy hiểm luôn xác nhận trước.

## 3. Design Style - Liquid Glass (theo ảnh mẫu)

### 3.1 Visual Language
- Nền: gradient mềm tone lạnh (blue/indigo/slate), chuyển sắc dịu.
- Khối chính (card/panel/dialog):
  - Glass blur nền
  - Border sáng mờ
  - Shadow nhẹ
  - Corner radius lớn (18-24)
- Tránh bề mặt đặc hoàn toàn; ưu tiên lớp bán trong suốt.

### 3.2 Composition Rules
- Mỗi màn có 1 lớp background thống nhất + nhiều GlassCard nổi trên cùng.
- Khoảng trắng rộng, group theo cụm chức năng.
- Icon đơn giản, bo tròn, đồng bộ stroke.

### 3.3 Motion & Feedback
- Animation ngắn và mượt (150-250ms), không giật.
- Drag/drop Kanban phải có trạng thái kéo rõ ràng (elevation/opacity/scale nhẹ).
- Nút/tile có pressed state tinh tế (không nhấp nháy gắt).

## 4. Theme Requirement
- Bắt buộc có 2 theme: Light Theme và Dark Theme.
- Mặc định ThemeMode.system.
- Chuẩn bị cấu trúc để thêm manual switch trong Settings (phase sau).
- Ở cả 2 mode phải đảm bảo:
  - Contrast đạt mức đọc tốt.
  - Glass effect vẫn phân lớp rõ foreground/background.
  - Không dùng màu neon hoặc bão hòa quá cao.

## 5. Information Architecture & Screens

### 5.1 Authentication
- Login
- Register
- Profile (view/update)
- Change password

### 5.2 Workspace
- Workspace list
- Create workspace
- Workspace detail
- Member management (invite, role update, remove)

### 5.3 Project
- Project list theo workspace
- Create project
- Update/Delete project

### 5.4 Task
- Task list theo project
- Create task
- Task detail/edit
- Assign member, deadline, priority, label

### 5.5 Kanban (core Trello-like)
- Board view theo cột status
- Drag & drop task card giữa các status
- Create new status
- Card preview gọn, mở detail nhanh

### 5.6 Collaboration
- Comment list trong task (kèm avatar)
- Add comment
- Mention user theo email
- Upload attachment

### 5.7 Notification
- Notification list
- Unread badge count
- Mark read / Mark all read

### 5.8 Dashboard
- My Dashboard (assigned/completed/overdue/due soon)
- Project Dashboard (completion %, tasks by status/priority)

## 6. Navigation Requirement
- Dùng GoRouter với route rõ ràng:
  - /login, /register
  - /workspaces
  - /workspaces/:id/projects
  - /projects/:id/kanban
  - /tasks/:id
  - /notifications
  - /dashboard
- Có route guard cho màn cần đăng nhập.
- Có deep-link structure cho phase sau.
- Back navigation phải nhất quán và không mất context (workspace/project hiện tại).

## 7. State & Data Requirement
- State management: Riverpod.
- API client: Dio + JWT interceptor.
- Lưu token local: SharedPreferences (hoặc secure storage phase nâng cao).
- Mỗi màn bắt buộc có 4 trạng thái: Loading, Success, Empty, Error (kèm retry).
- Refresh sau mutation (create/update/delete/drag-drop/comment) phải rõ ràng và nhất quán.

## 8. Reusable Component Requirement

### 8.1 Core Components
- GlassCard
- PrimaryButton / SecondaryButton
- AppTextField
- AppScaffold (background + appbar chuẩn)
- LoadingView
- EmptyStateView
- ErrorStateView
- StatusChip (priority/status)
- NotificationBadge

### 8.2 Trello-like Components (bổ sung bắt buộc)
- BoardColumn (status column)
- TaskCard (compact card chuẩn dùng chung list/kanban)
- AssigneeAvatarGroup
- LabelChipGroup
- QuickActionMenu (edit/move/delete)

## 9. UX Requirement
- Tốc độ phản hồi UI nội bộ cho thao tác chính < 300ms.
- Khi gọi API phải có feedback rõ (skeleton/loading/spinner).
- Hành động nguy hiểm cần confirm dialog.
- Form validate ngay trên UI (email format, password length, required fields).
- Kanban drag/drop mượt, có phản hồi trực quan và thông báo khi lỗi.
- Tránh multi-step không cần thiết cho thao tác thường xuyên (đặc biệt create/move/update task).

## 10. Accessibility Requirement
- Font nội dung thường >= 14.
- Tap target tối thiểu 44x44.
- Không dùng màu làm tín hiệu duy nhất, phải có icon/text bổ trợ.
- Dark mode không làm giảm readability.
- Trạng thái disabled/loading cần phân biệt rõ bằng hình thức + semantics.

## 11. Responsive Requirement
- Ưu tiên mobile portrait.
- Màn nhỏ <= 360 width không vỡ layout, không tràn text quan trọng.
- Tablet follow phase sau, nhưng component phải tách để mở rộng.

## 12. AI UI Generation Guardrails (để AI tuân thủ)

### 12.1 Must Follow
- Luôn bám mô hình Trello-like: board/card là trung tâm.
- Luôn dùng design language Liquid Glass cho bề mặt chính.
- Luôn dùng reusable component hiện có trước khi tạo component mới.
- Luôn thiết kế đủ trạng thái loading/empty/error/success cho từng màn.

### 12.2 Must Avoid
- Không thêm flow mới ngoài scope yêu cầu (không tự sinh extra page/modal/filter nếu chưa được yêu cầu).
- Không hard-code màu/shadow/font mới ngoài theme token.
- Không thay đổi hành vi điều hướng cốt lõi nếu chưa có yêu cầu product.
- Không đánh đổi readability để lấy hiệu ứng thị giác.

## 13. Ưu tiên triển khai (MVP)
- Phase 1: Auth + Workspace list + Project list + Task list + Kanban basic
- Phase 2: Collaboration + Notification + Dashboard
- Phase 3: Polish motion/UI, manual theme switch, accessibility nâng cao

## 14. Definition of Done (UI)
- Mỗi feature có màn hình chính và đủ trạng thái loading/empty/error/success.
- Theme Light/Dark đúng, không lỗi contrast.
- Reusable components được dùng thống nhất toàn app.
- GoRouter hoạt động đúng theo auth/role state.
- Match API contract trong docs/api_endpoints.md.
- Kanban interaction đạt trải nghiệm Trello-like (kéo thả rõ ràng, card mở nhanh, phản hồi tức thì).
