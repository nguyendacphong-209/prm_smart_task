# PRM Smart Task - Frontend (Flutter)

Smart Task Manager application with liquid-glass UI design, professional muted color palette, and smooth animations.

## 📋 Prerequisites

Trước khi bắt đầu, đảm bảo đã cài đặt các môi trường sau:

- **Flutter SDK**: Version 3.10.7 hoặc cao hơn ([Download](https://flutter.dev/docs/get-started/install))
- **Dart**: Đi kèm với Flutter
- **Android Studio** hoặc **Xcode**: Để chạy emulator/simulator
- **Git**: Để clone source code

## 🚀 Hướng Dẫn Chạy Local

### 1. Clone Source Code

```bash
git clone <repository-url>
cd prm_smart_task/frontend
```

### 2. Cài Đặt Dependencies

```bash
flutter pub get
```

### 3. Chạy Application

#### On Android Emulator:
```bash
flutter run
```

#### On iOS Simulator (macOS):
```bash
flutter run
```

#### On Specific Device:
```bash
flutter run -d <device-id>
```

Để xem danh sách device khả dụng:
```bash
flutter devices
```

### 4. Build APK (Android) / IPA (iOS)

#### Android:
```bash
flutter build apk --release
```

#### iOS:
```bash
flutter build ios --release
```

## Backend và Database

API mặc định của Flutter đang trỏ tới backend đã deploy trên Render. Khi backend đó đã được admin cấu hình kết nối PostgreSQL đã deploy, bạn chỉ cần chạy Flutter trên máy ảo Android; máy bạn không cần chạy backend hoặc PostgreSQL local. Luồng dữ liệu là:

```text
Android Emulator → Backend trên Render → PostgreSQL đã deploy
```

Admin cấu hình `DB_URL`, `DB_USERNAME` và `DB_PASSWORD` trong môi trường của backend. Flutter chỉ cần địa chỉ API; không đưa thông tin database vào app.

### Chạy với backend đã deploy

Khởi động Android Emulator rồi chạy:

```bash
flutter pub get
flutter run
```

Lệnh này dùng API mặc định trên Render. Nếu server đang ngủ hoặc khởi động lại, chờ một lúc rồi thử lại.

### Chạy backend trên máy bạn

Chỉ dùng cách này khi bạn muốn chạy Spring Boot local. Tạo database trước, rồi cấu hình thông tin PostgreSQL cho backend. Để emulator gọi backend trên máy tính, chạy Flutter với:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

`10.0.2.2` là địa chỉ Android Emulator dùng để truy cập máy tính đang chạy emulator. Có thể dùng PostgreSQL local hoặc database đã deploy mà backend local được phép truy cập; thông tin database vẫn chỉ cấu hình ở backend.

## 🎨 Thiết Kế UI

Ứng dụng sử dụng **Liquid Glass Design System** với:
- Muted professional color palette (blues, cyans, teals)
- Subtle glass-morphism effects (blur 3-8px, transparent overlays)
- Light & Dark mode support
- Responsive layout cho phone/tablet

## 📁 Cấu Trúc Project

```
lib/
├── main.dart                 # Entry point
├── app/                      # App configuration & router
├── core/                     # Core utilities (theme, config)
├── features/                 # Feature modules (task, dashboard, etc.)
├── shared/                   # Shared widgets & utilities
└── data/                     # API & data layer
```

## 🔧 Development Commands

### Code Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Format Code
```bash
dart format lib/
```

### Build Runner (Generate Code)
```bash
flutter pub run build_runner build
```

## 🐛 Troubleshooting

### Lỗi Dependencies Mismatch
```bash
flutter clean
flutter pub get
```

### Android Emulator không chạy
```bash
flutter emulators --launch <emulator-name>
```

### iOS Build Fails
```bash
cd ios
pod repo update
cd ..
flutter ios --clean
```

## 📚 Tài Liệu Thêm

- [Flutter Official Docs](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Dio HTTP Client](https://pub.dev/packages/dio)

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra Backend đang hoạt động: Mở web browser vào API endpoint
2. Chạy `flutter doctor` để kiểm tra environment
3. Xem logs: `flutter run -v`

Thông tin hỗ trợ : dacphong2092003@gmail.com (Liên hệ tôi)
