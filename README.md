# 📚 StudyBuddy - Ứng Dụng Học Tập Thông Minh

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Tổng Quan

**StudyBuddy** là một ứng dụng học tập thông minh được thiết kế đặc biệt cho học sinh THPT tại Việt Nam. Ứng dụng giúp học sinh quản lý bài tập, lập kế hoạch học tập và theo dõi tiến độ một cách hiệu quả.

### ✨ Tính Năng Chính

- **📚 Quản lý bài tập**: Thêm, sửa, xóa và theo dõi bài tập
- **📅 Lịch học tập**: Lập kế hoạch và theo dõi lịch học
- **📊 Thống kê**: Biểu đồ tiến độ và thành tích học tập
- **🏆 Hệ thống thành tích**: Huy hiệu và điểm kinh nghiệm
- **🌙 Chế độ tối**: Giao diện đẹp mắt với dark mode
- **📱 Đa nền tảng**: Hỗ trợ Android, iOS và Web

## 🚀 Cài Đặt & Chạy

### Yêu Cầu Hệ Thống

- **Flutter SDK**: 3.16.0 trở lên
- **Dart SDK**: 3.2.0 trở lên
- **Android Studio** hoặc **VS Code**
- **Git**: 2.30+

### Bước 1: Clone Repository

```bash
git clone https://github.com/your-username/studybuddy.git
cd studybuddy
```

### Bước 2: Cài Đặt Dependencies

```bash
flutter pub get
```

### Bước 3: Cấu Hình Firebase (Tùy Chọn)

1. Tạo dự án Firebase mới
2. Bật Authentication và Firestore
3. Cập nhật `lib/main.dart` với thông tin Firebase của bạn

### Bước 4: Chạy Ứng Dụng

```bash
# Chạy trên thiết bị được kết nối
flutter run

# Chạy trên web
flutter run -d chrome

# Build cho Android
flutter build apk --release

# Build cho iOS
flutter build ios --release
```

## 📱 Giao Diện & Tính Năng

### 🏠 Dashboard (Trang Chủ)

- **Thống kê nhanh**: Hiển thị tổng quan bài tập và tiến độ
- **Bài tập hôm nay**: Danh sách bài tập cần làm
- **Tiến độ học tập**: Biểu đồ và mục tiêu
- **Thao tác nhanh**: Thêm bài tập, xem lịch, thống kê

### 📝 Quản Lý Bài Tập

- **Thêm bài tập**: Tên, mô tả, môn học, deadline, ưu tiên
- **Lọc và tìm kiếm**: Theo môn học, trạng thái, thời gian
- **Chỉnh sửa**: Sửa thông tin bài tập
- **Hoàn thành**: Đánh dấu bài tập đã hoàn thành
- **Thống kê**: Số lượng bài tập theo trạng thái

### 📅 Lịch Học Tập

- **Lịch tháng**: Xem và quản lý sự kiện theo tháng
- **Thêm sự kiện**: Lịch học, deadline, sự kiện quan trọng
- **Lọc theo ngày**: Xem sự kiện của ngày được chọn
- **Thống kê**: Số lượng sự kiện theo thời gian

### 👤 Hồ Sơ Người Dùng

- **Thông tin cá nhân**: Tên, lớp, trường
- **Thống kê học tập**: Bài tập hoàn thành, thời gian học
- **Thành tích**: Huy hiệu và điểm kinh nghiệm
- **Mục tiêu học tập**: Theo dõi tiến độ mục tiêu
- **Cài đặt**: Thông báo, chế độ tối, đồng bộ

## 🎨 Thiết Kế & Giao Diện

### 🎨 Theme System

- **Light Theme**: Giao diện sáng với màu sắc tươi mới
- **Dark Theme**: Giao diện tối bảo vệ mắt
- **Gradient Cards**: Card với gradient đẹp mắt
- **Glass Effect**: Hiệu ứng kính mờ hiện đại
- **Animations**: Chuyển động mượt mà và tự nhiên

### 🎯 Color Palette

```dart
// Màu sắc chính
primaryColor: #6366F1 (Indigo)
secondaryColor: #EC4899 (Pink)
accentColor: #10B981 (Emerald)
warningColor: #F59E0B (Amber)
errorColor: #EF4444 (Red)
```

### 📱 Responsive Design

- **Mobile First**: Tối ưu cho điện thoại
- **Tablet Support**: Giao diện thích ứng cho tablet
- **Web Ready**: Hỗ trợ chạy trên web

## 🏗️ Kiến Trúc Dự Án

### 📁 Cấu Trúc Thư Mục

```
lib/
├── core/                          # 🧠 Tiện ích cốt lõi
│   ├── config/                    # ⚙️ Cấu hình
│   ├── constants/                 # 📋 Hằng số
│   ├── services/                  # 🔧 Dịch vụ
│   ├── theme/                     # 🎨 Giao diện
│   ├── utils/                     # 🛠️ Tiện ích
│   └── navigation/                # 🧭 Điều hướng
├── data/                          # 💾 Tầng dữ liệu
│   ├── models/                    # 📊 Mô hình
│   ├── repositories/              # 🏪 Repository
│   └── datasources/               # 🔌 Nguồn dữ liệu
├── presentation/                   # 🎨 Tầng giao diện
│   ├── screens/                   # 📱 Màn hình
│   ├── widgets/                   # 🧩 Widget
│   └── providers/                 # 🎛️ Provider
└── main.dart                      # 🚀 Điểm khởi đầu
```

### 🔧 Công Nghệ Sử Dụng

#### Frontend
- **Flutter 3.16.0**: Framework đa nền tảng
- **Dart 3.2.0**: Ngôn ngữ lập trình
- **Material Design 3**: Hệ thống thiết kế
- **Riverpod**: Quản lý trạng thái
- **GoRouter**: Điều hướng

#### Backend & Services
- **Firebase Firestore**: Cơ sở dữ liệu NoSQL
- **Firebase Auth**: Xác thực người dùng
- **Firebase Analytics**: Phân tích hành vi
- **Firebase Crashlytics**: Báo cáo lỗi
- **Firebase Performance**: Giám sát hiệu suất

#### Local Storage
- **SQLite**: Cơ sở dữ liệu cục bộ
- **SharedPreferences**: Lưu trữ cài đặt
- **Hive**: Lưu trữ NoSQL cục bộ

## 🚀 Tính Năng Nâng Cao

### 🎮 Gamification

- **Hệ thống điểm**: Tích lũy điểm kinh nghiệm
- **Huy hiệu**: Thành tích và danh hiệu
- **Cấp độ**: Nâng cấp level theo hoạt động
- **Chuỗi ngày**: Theo dõi ngày học liên tiếp

### 📊 Analytics & Insights

- **Thống kê chi tiết**: Theo môn học và thời gian
- **Biểu đồ tiến độ**: Trực quan hóa dữ liệu
- **Phân tích hành vi**: Hiểu thói quen học tập
- **Báo cáo định kỳ**: Tổng kết hàng tuần/tháng

### 🔔 Thông Báo Thông Minh

- **Nhắc nhở deadline**: Thông báo bài tập sắp hạn
- **Lịch học**: Nhắc nhở lịch học hàng ngày
- **Thành tích**: Thông báo khi đạt thành tích
- **Khuyến khích**: Thông báo động viên học tập

## 🧪 Testing

### Unit Tests

```bash
# Chạy tất cả unit tests
flutter test

# Chạy test cụ thể
flutter test test/unit/task_repository_test.dart
```

### Widget Tests

```bash
# Chạy widget tests
flutter test test/widget_test.dart
```

### Integration Tests

```bash
# Chạy integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Build & Deploy

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ~/upload-keystore.jks app-release-unsigned.apk upload
```

### iOS

```bash
# Build iOS
flutter build ios --release

# Archive for App Store
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/ios/Runner.xcarchive
```

### Web

```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## 🤝 Đóng Góp

### Quy Trình Phát Triển

1. **Fork repository**
2. **Tạo nhánh tính năng**:
   ```bash
   git checkout -b feature/tinh-nang-moi
   ```
3. **Thực hiện thay đổi** và commit:
   ```bash
   git commit -m 'feat: thêm tính năng mới'
   ```
4. **Đẩy lên nhánh**:
   ```bash
   git push origin feature/tinh-nang-moi
   ```
5. **Tạo Pull Request**

### Tiêu Chuẩn Code

#### Dart/Flutter
- **Hướng dẫn style Dart**: Tuân theo hướng dẫn style Dart chính thức
- **Quy ước Flutter**: Sử dụng best practices Flutter
- **Tài liệu**: Viết tài liệu cho API công khai
- **Kiểm thử**: Viết unit test và widget test

#### Git
- **Commit messages**: Sử dụng conventional commits
- **Đặt tên nhánh**: `feature/`, `bugfix/`, `hotfix/`
- **Pull requests**: Bao gồm mô tả và ảnh chụp màn hình

## 📄 Giấy Phép

Dự án này được cấp phép theo MIT License - xem file [LICENSE](LICENSE) để biết chi tiết.

## 📞 Hỗ Trợ & Liên Hệ

### Thông Tin Liên Hệ
- **Email**: support@studybuddy.com
- **Website**: https://studybuddy.com
- **Tài liệu**: https://docs.studybuddy.com

### Cộng Đồng
- **GitHub Issues**: [Báo cáo lỗi](https://github.com/your-username/studybuddy/issues)
- **Discord**: [Tham gia cộng đồng](https://discord.gg/studybuddy)
- **Telegram**: [Kênh tin tức](https://t.me/studybuddy)

## 🙏 Lời Cảm Ơn

- **Đội ngũ Flutter**: Vì framework tuyệt vời
- **Đội ngũ Firebase**: Vì các dịch vụ backend mạnh mẽ
- **Material Design**: Vì hệ thống thiết kế đẹp mắt
- **Cộng đồng mã nguồn mở**: Vì các package tuyệt vời

---

**Được tạo với ❤️ bởi Đội Ngũ StudyBuddy**

## 📝 Changelog

### Version 1.0.0 (2024-01-XX)
- ✨ Tính năng quản lý bài tập cơ bản
- 🎨 Giao diện hiện đại với Material Design 3
- 🌙 Hỗ trợ chế độ tối
- 📱 Responsive design cho mobile và tablet
- 🔧 Cấu trúc dự án clean architecture
- 🧪 Unit tests và widget tests
- 📦 Build system cho Android, iOS và Web

---

**StudyBuddy - Học tập thông minh, tương lai tươi sáng! 🚀**
