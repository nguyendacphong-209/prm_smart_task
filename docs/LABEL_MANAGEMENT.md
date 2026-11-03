# Quản lý nhãn trong project

Mở danh sách task → biểu tượng nhãn trên thanh tiêu đề → Quản lý nhãn.
Tạo nhãn, sửa tên/màu hoặc xóa với xác nhận. Đóng màn hình sẽ tải lại task và bỏ bộ lọc nhãn cũ. Form tạo/sửa task lấy lại danh sách nhãn khi mở.

## Quyền và dữ liệu
- Chủ workspace hoặc admin đã chấp nhận lời mời được tạo/sửa/xóa.
- API GET danh sách nhãn hiện có được giữ nguyên.
- Tên được trim, không rỗng, tối đa 100 ký tự, không trùng tên trong project (không phân biệt hoa thường).
- Màu dạng #RRGGBB.
- Xóa nhãn gỡ các dòng liên kết task_labels trước khi xóa labels, trong cùng transaction. Không xóa task.
- Dùng bảng labels và task_labels hiện có. Không có migration hoặc cấu hình database mới.

## API mới
- POST /api/projects/{projectId}/labels
- PUT /api/projects/{projectId}/labels/{labelId}
- DELETE /api/projects/{projectId}/labels/{labelId}
Body tạo/sửa: {"name":"Bug","color":"#F44336"}.
Backend cần được deploy trước khi kiểm thử giao diện với server Render.

## Kiểm thử thủ công
1. Dùng chủ workspace/admin, tạo Bug màu đỏ, kiểm tra danh sách.
2. Thử tên trống, tên quá dài, tên trùng và mã màu sai.
3. Gắn Bug vào một task, đổi tên/màu nhãn, quay lại danh sách task và kiểm tra bộ lọc, form sửa task.
4. Hủy xóa: dữ liệu giữ nguyên. Xác nhận xóa: nhãn mất khỏi danh sách và task, task vẫn còn.
5. Thử bằng member thường và admin chưa chấp nhận lời mời: API thay đổi phải trả 403.
6. Gửi ID nhãn project khác: từ chối, không sửa hoặc gỡ liên kết.
7. Tải lại trang, kiểm tra dữ liệu còn được lưu.

Không lưu tài khoản/mật khẩu kiểm thử trong repository.

## Kết quả kiểm tra ở máy phát triển
- 12/12 LabelServiceTest đạt bằng JUnit Platform + Mockito javaagent, dùng dependency cache và thư mục tạm bên ngoài repo (Gradle bị khóa cache).
- Dart analyzer: không có vấn đề trong màn hình quản lý nhãn, task_list_page và test mới.
- Hai widget test đã viết nhưng chưa chạy được: native asset objective_c lỗi -1073741816 trước khi vào test, cả Windows và Chrome.
- Chưa kiểm thử với PostgreSQL/Render hoặc tài khoản thật; cần deploy backend mới.
