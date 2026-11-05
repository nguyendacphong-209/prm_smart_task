# Ghim task cá nhân

## Sử dụng
- Danh sách task: bấm biểu tượng bookmark để ghim/bỏ ghim.
- Màn hình chính → Đã ghim, hoặc nút Task đã ghim trên danh sách task.
- Danh sách gom các project, sắp xếp ghim mới nhất trước. Bấm task để mở chi tiết; bấm bookmark để bỏ ghim.
- Ghim chỉ thuộc tài khoản đang đăng nhập, không thay đổi ưu tiên/trạng thái/người phụ trách.
- Chỉ chủ workspace hoặc thành viên đã chấp nhận lời mời được ghim/xem task.
- Mất quyền thì task bị ẩn khỏi danh sách. Nếu được cấp lại quyền, bookmark cũ có thể hiện lại.
- Xóa task hoặc tài khoản sẽ xóa bookmark tương ứng nhờ khóa ngoại CASCADE.

## Database và triển khai
Nhóm trưởng chạy docs/migrations/003_task_pins.sql trên PostgreSQL trước khi deploy backend mới.
Bảng mới task_pins, khóa chính (user_id, task_id), thời gian pinned_at. Không thay đổi dữ liệu task hiện có.
Không cần cấu hình môi trường mới. Chưa chạy migration trên database thật.
API dùng JDBC và SQL PostgreSQL; Hibernate không tự tạo bảng bookmark, phải chạy migration.

## API
- GET /api/me/pinned-tasks: danh sách của người đang đăng nhập, chỉ task còn quyền truy cập.
- PUT /api/tasks/{taskId}/pin: ghim, 204; gọi lại không tạo trùng hoặc đổi thời gian ghim.
- DELETE /api/tasks/{taskId}/pin: bỏ ghim của chính người dùng, 204 kể cả khi đã bỏ ghim.
Không nhận userId từ client. Task không tồn tại/không có quyền ghim trả 404.

## Kiểm thử toàn luồng sau deploy
1. A ghim một task, tải lại trang và đăng nhập trên thiết bị khác: vẫn thấy ghim.
2. B đăng nhập: không thấy ghim riêng của A; B có thể ghim cùng task độc lập.
3. A bỏ ghim: task và ghim của B vẫn còn.
4. Mời C nhưng chưa chấp nhận: C không ghim/xem được; sau chấp nhận thì được.
5. Thu hồi quyền thành viên: task của workspace đó không xuất hiện trong danh sách ghim.
6. Xóa task: bookmark mất, GET không lỗi.
7. Ghim hai lần cùng task: một dòng; bỏ ghim hai lần: không lỗi.
8. Mạng lỗi: có nút thử lại, không hiển thị thông báo thành công giả.

## Kết quả kiểm tra local
- 8/8 JUnit service tests đạt (JUnit launcher + Mockito javaagent, dùng dependency cache, không sửa build.gradle).
- 3/3 Flutter widget tests đạt: ghim/bỏ ghim, lỗi lưu giữ trạng thái, danh sách hiển thị task/project.
- Dart analyzer các file liên quan: No issues found.
- 13 assertion kiểm tra logic SQL qua SQLite: tách người dùng, thành viên pending, mất quyền, ghim lặp và cascade xóa task. Đây không thay thế kiểm thử tích hợp PostgreSQL.
- Chưa chạy migration hoặc API trên Render/database thật.
