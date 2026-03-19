SOFTWARE PROJECT PROPOSAL
1. Project Information
Project Name:
Smart Task Manager
Project Type:
Mobile Application
Platform:
Mobile (Android / iOS)
Team Members:
No
Name
Role
Git 
1
Nguyễn Đắc Phong 
Project Leader
phongndde170408@fpt.edu.vn
2
Nguyễn Thành Nhân
Member


3
Nguyễn Việt Khoa
Member
vjtkho-kaan
4
Lê Đức Minh
Member
ducminh1902
5
Nguyễn Trọng Trí
Member
trongtri212003
6 
Võ Văn Phúc
Member
phucvok91@gmail.com

Instructor / Supervisor:
Thầy Nam

2. Product Description
Smart Task Manager là một ứng dụng quản lý công việc giúp người dùng tổ chức, theo dõi và cộng tác trong các dự án cá nhân hoặc nhóm.
Ứng dụng cho phép người dùng:
Tạo và quản lý workspace
Quản lý project và task
Phân công công việc cho thành viên
Theo dõi tiến độ công việc bằng Kanban board
Thêm deadline, priority và label
Bình luận và cộng tác trong task
Nhận thông báo khi có thay đổi
Ứng dụng hướng tới việc thay thế các công cụ quản lý công việc phổ biến như Notion hoặc Trello trong quy mô nhỏ đến trung bình.

3. Target Users
Sinh viên làm đồ án nhóm
Nhóm phát triển phần mềm nhỏ
Người làm việc freelance
Người muốn quản lý công việc cá nhân

4. Main Features
1. User Management
Đăng ký tài khoản
Đăng nhập
Đăng xuất
Cập nhật hồ sơ cá nhân
2. Workspace Management
Tạo workspace
Mời thành viên vào workspace
Quản lý danh sách thành viên
3. Project Management
Tạo project
Chỉnh sửa project
Xóa project
Xem danh sách project
4. Task Management
Tạo task
Chỉnh sửa task
Xóa task
Gán task cho thành viên
Đặt deadline
Thêm label
Đặt priority
5. Kanban Board
Xem task theo dạng board
Drag & drop task giữa các trạng thái
Tạo trạng thái task mới
6. Collaboration
Comment trong task
Mention thành viên
Upload file đính kèm
7. Notification
Thông báo khi task được giao
Thông báo khi task thay đổi trạng thái
8. Dashboard
Thống kê số lượng task
Theo dõi tiến độ project

5. Main Use Cases
Use Case ID
Use Case Name
Description
UC01
Register
Người dùng tạo tài khoản
UC02
Login
Người dùng đăng nhập hệ thống
UC03
Create Workspace
Tạo workspace mới
UC04
Invite Member
Mời thành viên vào workspace
UC05
Create Project
Tạo project mới
UC06
Create Task
Tạo task mới
UC07
Assign Task
Giao task cho thành viên
UC08
Update Task Status
Cập nhật trạng thái task
UC09
Comment Task
Bình luận trong task
UC10
View Dashboard
Xem thống kê project


6. Use Case Flow Example
Use Case: Create Task
Actor: User
Precondition:
User đã đăng nhập
User đang ở trong một project
Main Flow:
User chọn project
User nhấn nút "Create Task"
User nhập thông tin task:
Title
Description
Deadline
Priority
User chọn assignee
User nhấn Save
System lưu task vào database
Task hiển thị trên Kanban board
Post-condition:
Task mới được tạo thành công.

7. Functional Requirements
FR1: Hệ thống phải cho phép người dùng đăng ký và đăng nhập.
FR2: Người dùng phải có thể tạo workspace.
FR3: Người dùng phải có thể tạo project trong workspace.
FR4: Người dùng phải có thể tạo và chỉnh sửa task.
FR5: Người dùng phải có thể giao task cho thành viên.
FR6: Hệ thống phải cho phép comment trong task.
FR7: Hệ thống phải hiển thị task dưới dạng Kanban board.
FR8: Hệ thống phải gửi thông báo khi task thay đổi.

8. Non-Functional Requirements
Performance
Hệ thống phải phản hồi API dưới 2 giây.
Security
Mật khẩu phải được mã hóa.
Sử dụng authentication token.
Scalability
Backend phải hỗ trợ nhiều user đồng thời.
Usability
Giao diện phải thân thiện với người dùng.

9. Technology Stack
Frontend (Mobile)
Flutter
Riverpod (State Management)
Dio (HTTP Client)
GoRouter (Navigation)
Backend
Spring Boot hoặc NestJS
REST API
Database
PostgreSQL
Local Storage
Hive
SharedPreferences

10. System Architecture
Client (Mobile App)
↓
REST API
↓
Backend Server
↓
Database

11. Future Improvements
Real-time collaboration
Calendar view
Mobile push notification
AI task suggestion
Time tracking

12. Conclusion
Smart Task Manager là một ứng dụng quản lý công việc hiện đại giúp người dùng quản lý dự án hiệu quả hơn. Hệ thống được thiết kế với kiến trúc client-server và sử dụng các công nghệ hiện đại để đảm bảo khả năng mở rộng và hiệu suất.

