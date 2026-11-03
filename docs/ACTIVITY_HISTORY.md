# Lịch sử hoạt động task

- GET /api/tasks/{taskId}/activities?page=0: 20 bản ghi/trang, mới nhất trước. Chỉ thành viên đã được chấp nhận trong workspace được đọc.
- Theo dõi title, description, deadline, assignees và status qua cập nhật task hoặc Kanban. Không ghi nếu không đổi dữ liệu.
- Lưu cùng transaction với thay đổi task; lưu tên người thao tác và giá trị trước/sau tại thời điểm thay đổi. Thời gian sự kiện là UTC, UI hiển thị giờ thiết bị.
- Lịch sử chỉ bắt đầu từ khi backend mới được chạy. Không dựng lại sự kiện cũ.
- UI: Chi tiết task → Lịch sử hoạt động; có Làm mới, Thử lại và Xem thêm.

## Triển khai
Chạy docs/migrations/002_task_activities.sql trên database đích trước khi chạy backend mới (đặc biệt khi JPA_DDL_AUTO=validate). Migration là SQL thủ công, dự án chưa tự chạy migration này.
Flutter hiện gọi backend Render được cấu hình trong ApiConstants. Chỉ reload Flutter sẽ chưa đủ: cần triển khai backend mới và migration trên cùng môi trường, hoặc cấu hình Flutter gọi backend local để thử.

## Kiểm tra thủ công
1. Thành viên A đổi tiêu đề/mô tả/deadline/người phụ trách của task. Kiểm tra lịch sử đúng A và trước/sau.
2. Lưu lại cùng giá trị: không sinh sự kiện mới. Đổi thứ tự danh sách assignee: không sinh sự kiện.
3. Xóa hết assignee: lịch sử hiển thị Sau: Chưa có.
4. Kéo Kanban sang cột khác: một sự kiện trạng thái. Kéo lại cùng cột: không có sự kiện mới.
5. Thành viên B trong workspace đọc được; tài khoản ngoài workspace không đọc được bằng API.
6. Hơn 20 sự kiện: Xem thêm hiển thị trang tiếp theo.
7. API cập nhật thất bại: không lưu lịch sử của giao dịch bị rollback.

## Giới hạn
Deadline đang giữ nguyên ngữ nghĩa API cũ: null không xóa deadline, do đó tính năng này ghi nhận thay đổi deadline được API chấp nhận. Không thêm sửa/xóa lịch sử. Bản ghi dùng UUID dạng scalar để không chặn luồng xóa task hiện tại; sau khi task bị xóa, endpoint lịch sử không còn cho truy cập. Cần chính sách dọn lịch sử nếu triển khai lâu dài.
