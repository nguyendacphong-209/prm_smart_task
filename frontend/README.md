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

## 🌐 Backend & Database Information

**✅ Backend (Spring Boot) & Database (PostgreSQL) đang được deploy trên Render**

- **Bạn chỉ cần chạy Flutter Frontend trên local - không cần setup backend/database**
- Frontend app sẽ tự động kết nối đến API trên Render
- API endpoint được cấu hình sẵn trong file cấu hình ứng dụng

### ⚠️ Lưu Ý Về Render Deployment

Nếu bạn thấy lỗi kết nối hoặc app bị chậm khi khởi động lần đầu:
- **Render có thể đang khởi tạo lại server** sau một khoảng thời gian không hoạt động
- **Hãy đợi khoảng 1-2 phút** rồi thử lại
- Những lần tiếp theo sẽ nhanh hơn khi server đã "warm up"

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
