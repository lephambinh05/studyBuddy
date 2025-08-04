# StudyBuddy - Ứng Dụng Học Tập Thông Minh

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

#

## 📱 Tính Năng Chính

### ✅ Tính Năng MVP (Giai Đoạn 1) - Đã Hoàn Thành
- **📚 Quản lý bài tập**: Thêm, sửa, xóa, đánh dấu hoàn thành bài tập
- **📅 Lập kế hoạch học tập**: Tạo lịch học cá nhân theo từng môn học
- **⏰ Đếm ngược kỳ thi**: Theo dõi thời gian đến kỳ thi quan trọng
- **🔔 Nhắc nhở thông minh**: Thông báo deadline và lịch học tự động
- **🔄 Đồng bộ dữ liệu**: Hybrid/Offline-first với Firebase Firestore
- **👤 Xác thực người dùng**: Đăng nhập/đăng ký với Firebase Auth
- **📊 Thống kê học tập**: Biểu đồ tiến độ và thành tích học tập

### 🚧 Tính Năng Nâng Cao (Giai Đoạn 2) - Đang Phát Triển
- **🏆 Hệ thống phần thưởng**: Huy hiệu, điểm kinh nghiệm, cấp độ, chuỗi ngày học
- **📊 Phân tích nâng cao**: Thống kê chi tiết theo môn học và thời gian
- **👥 Tính năng xã hội**: Chia sẻ thành tích, nhóm học tập, leaderboard
- **📲 Thông báo đẩy**: Thông báo thông minh dựa trên hành vi học tập
- **🎯 Mục tiêu học tập**: Đặt và theo dõi mục tiêu học tập cá nhân
- **📚 Tài liệu học tập**: Kho tài liệu và bài tập mẫu

## 🛠 Công Nghệ Sử Dụng

### Giao Diện Người Dùng
- **Flutter 3.16.0**: Framework đa nền tảng cho Android và iOS
- **Dart 3.2.0**: Ngôn ngữ lập trình hiện đại và hiệu suất cao
- **Material Design 3**: Hệ thống thiết kế UI/UX đẹp mắt và nhất quán
- **Provider/Riverpod**: Quản lý trạng thái ứng dụng hiệu quả
- **GoRouter**: Điều hướng màn hình linh hoạt và mạnh mẽ

### Hệ Thống Backend & Dịch Vụ
- **Firebase Firestore**: Cơ sở dữ liệu NoSQL real-time
- **Firebase Auth**: Xác thực người dùng an toàn
- **Firebase Analytics**: Phân tích hành vi người dùng chi tiết
- **Firebase Crashlytics**: Báo cáo lỗi tự động
- **Firebase Performance**: Giám sát hiệu suất ứng dụng
- **Firebase Cloud Messaging**: Thông báo đẩy thông minh

### Lưu Trữ Cục Bộ
- **SQLite**: Cơ sở dữ liệu cục bộ cho hoạt động offline
- **SharedPreferences**: Lưu trữ cài đặt và dữ liệu nhỏ
- **Hive**: Lưu trữ NoSQL cục bộ hiệu suất cao

## 📁 Cấu Trúc Dự Án Chi Tiết

```
lib/
├── core/                          # 🧠 Tiện ích cốt lõi
│   ├── config/                    # ⚙️ Cấu hình ứng dụng
│   │   └── app_config.dart       # Cấu hình tập trung (API keys, flags)
│   ├── constants/                 # 📋 Hằng số ứng dụng
│   │   ├── app_colors.dart       # Bảng màu và theme
│   │   ├── app_routes.dart       # Định nghĩa đường dẫn màn hình
│   │   └── app_strings.dart      # Hằng số chuỗi đa ngôn ngữ
│   ├── services/                  # 🔧 Dịch vụ cốt lõi
│   │   ├── analytics_service.dart # Theo dõi phân tích người dùng
│   │   ├── connectivity_service.dart # Giám sát kết nối mạng
│   │   ├── error_handler_service.dart # Xử lý lỗi tập trung
│   │   ├── logger_service.dart   # Hệ thống ghi log
│   │   ├── performance_service.dart # Giám sát hiệu suất
│   │   └── sync_service.dart     # Đồng bộ dữ liệu online/offline
│   └── utils/                     # 🛠️ Hàm tiện ích
│       └── validation_utils.dart # Kiểm tra đầu vào người dùng
├── data/                          # 💾 Tầng dữ liệu
│   ├── models/                    # 📊 Mô hình dữ liệu
│   │   ├── task.dart             # Mô hình bài tập (id, title, deadline, status)
│   │   ├── user.dart             # Mô hình người dùng (profile, preferences)
│   │   └── study_plan.dart       # Mô hình kế hoạch học tập
│   ├── repositories/              # 🏪 Mẫu Repository Pattern
│   │   └── task_repository.dart  # Thao tác dữ liệu bài tập (CRUD)
│   └── datasources/               # 🔌 Nguồn dữ liệu
│       ├── local/                 # 💻 Nguồn dữ liệu cục bộ
│       │   └── local_database.dart # Cơ sở dữ liệu SQLite
│       └── remote/                # 🌐 Nguồn dữ liệu từ xa
│           └── firebase_firestore.dart # Firebase Firestore
├── presentation/                   # 🎨 Tầng giao diện
│   ├── screens/                   # 📱 Màn hình ứng dụng
│   │   ├── auth/                 # 🔐 Màn hình xác thực
│   │   │   ├── login_screen.dart # Đăng nhập
│   │   │   ├── register_screen.dart # Đăng ký
│   │   │   └── forgot_password_screen.dart # Quên mật khẩu
│   │   ├── dashboard/            # 🏠 Màn hình chính
│   │   │   ├── dashboard_screen.dart # Bảng điều khiển tổng quan
│   │   │   ├── tasks/            # 📝 Quản lý bài tập
│   │   │   │   └── tasks_screen.dart # Danh sách và thêm bài tập
│   │   │   ├── calendar/         # 📅 Lịch học tập
│   │   │   │   └── calendar_screen.dart # Lịch và kế hoạch
│   │   │   └── profile/          # 👤 Hồ sơ người dùng
│   │   │       └── profile_screen.dart # Thông tin cá nhân
│   │   ├── onboarding/           # 🎯 Màn hình hướng dẫn
│   │   │   └── onboarding_screen.dart # Giới thiệu ứng dụng
│   │   └── splash/               # ⚡ Màn hình khởi động
│   │       └── splash_screen.dart # Loading và kiểm tra trạng thái
│   ├── widgets/                   # 🧩 Widget tái sử dụng
│   │   ├── common/               # 🔧 Widget chung
│   │   │   └── sync_status_widget.dart # Chỉ báo trạng thái đồng bộ
│   │   └── task/                 # 📋 Widget liên quan bài tập
│   │       ├── task_card.dart    # Card hiển thị bài tập
│   │       └── task_form.dart    # Form thêm/sửa bài tập
│   └── providers/                 # 🎛️ Quản lý trạng thái
│       └── task_provider.dart    # Quản lý trạng thái bài tập
├── scripts/                       # 🔧 Script tiện ích
│   ├── firebase_data_seeder.dart # 🌱 Script tạo dữ liệu mẫu
│   ├── simple_firebase_seeder.dart # 🚀 Script đơn giản hóa
│   └── run_firebase_seeder.dart  # ▶️ Script chạy seeder
└── main.dart                     # 🚀 Điểm khởi đầu ứng dụng
```

## 🔧 Chức Năng Từng File Quan Trọng

### 📱 Màn Hình Chính (Screens)

#### `lib/presentation/screens/auth/`
- **`login_screen.dart`**: Màn hình đăng nhập với email/password và Google
- **`register_screen.dart`**: Màn hình đăng ký tài khoản mới
- **`forgot_password_screen.dart`**: Khôi phục mật khẩu qua email

#### `lib/presentation/screens/dashboard/`
- **`dashboard_screen.dart`**: Màn hình chính hiển thị tổng quan học tập
- **`tasks_screen.dart`**: Quản lý danh sách bài tập (thêm, sửa, xóa, hoàn thành)
- **`calendar_screen.dart`**: Lịch học tập và kế hoạch theo ngày/tuần/tháng
- **`profile_screen.dart`**: Hồ sơ cá nhân, cài đặt và thống kê

### 🧩 Widget Tái Sử Dụng

#### `lib/presentation/widgets/`
- **`sync_status_widget.dart`**: Hiển thị trạng thái đồng bộ dữ liệu
- **`task_card.dart`**: Card hiển thị thông tin bài tập
- **`task_form.dart`**: Form thêm/sửa bài tập với validation

### 💾 Quản Lý Dữ Liệu

#### `lib/data/models/`
- **`task.dart`**: Định nghĩa cấu trúc dữ liệu bài tập
- **`user.dart`**: Định nghĩa thông tin người dùng
- **`study_plan.dart`**: Định nghĩa kế hoạch học tập

#### `lib/data/repositories/`
- **`task_repository.dart`**: Xử lý logic nghiệp vụ bài tập (CRUD operations)

### 🔧 Dịch Vụ Cốt Lõi

#### `lib/core/services/`
- **`analytics_service.dart`**: Theo dõi hành vi người dùng
- **`connectivity_service.dart`**: Kiểm tra kết nối mạng
- **`error_handler_service.dart`**: Xử lý lỗi tập trung
- **`sync_service.dart`**: Đồng bộ dữ liệu online/offline

### 🔧 Script Tiện Ích

#### `lib/scripts/`
- **`firebase_data_seeder.dart`**: Tạo dữ liệu mẫu cho Firebase
- **`simple_firebase_seeder.dart`**: Phiên bản đơn giản hóa của seeder
- **`run_firebase_seeder.dart`**: Script chạy seeder với khởi tạo Firebase

## 🚀 Hướng Dẫn Sử Dụng

### 📋 Cách Chạy Script Firebase Seeder

Script seeder được tạo để tự động tạo dữ liệu mẫu vào Firebase Firestore:

```bash
# Chạy script seeder đơn giản (khuyến nghị)
dart lib/scripts/simple_firebase_seeder.dart

# Hoặc chạy script seeder đầy đủ
dart lib/scripts/run_firebase_seeder.dart
```

**Dữ liệu mẫu sẽ được tạo:**
- 👥 **Users**: 2-3 tài khoản học sinh mẫu
- 📝 **Tasks**: 5-10 bài tập mẫu với deadline và ưu tiên
- 📚 **Subjects**: 5 môn học chính (Toán, Văn, Anh, Lý, Hóa)
- 🏆 **Achievements**: Hệ thống thành tích và huy hiệu
- 📅 **Study Plans**: Kế hoạch học tập mẫu
- 🔔 **Notifications**: Thông báo mẫu

### 📱 Cách Sử Dụng Ứng Dụng

#### 1. Đăng Ký/Đăng Nhập
- Tạo tài khoản mới hoặc đăng nhập với Google
- Hoàn thành hồ sơ cá nhân (lớp, trường, môn học yêu thích)

#### 2. Quản Lý Bài Tập
- **Thêm bài tập**: Nhấn "+" để thêm bài tập mới
- **Chỉnh sửa**: Nhấn vào bài tập để sửa thông tin
- **Hoàn thành**: Đánh dấu ✓ khi hoàn thành bài tập
- **Lọc và tìm kiếm**: Theo môn học, trạng thái, deadline

#### 3. Lập Kế Hoạch Học Tập
- **Tạo lịch học**: Lên kế hoạch học tập theo ngày/tuần
- **Đặt mục tiêu**: Thiết lập mục tiêu học tập cá nhân
- **Theo dõi tiến độ**: Xem biểu đồ tiến độ học tập

#### 4. Theo Dõi Kỳ Thi
- **Thêm kỳ thi**: Nhập thông tin kỳ thi quan trọng
- **Đếm ngược**: Xem thời gian còn lại đến kỳ thi
- **Nhắc nhở**: Nhận thông báo trước kỳ thi

## 🎯 Đối Tượng Người Dùng

### 👥 Học Sinh THPT
- **Lớp 10-12**: Tập trung vào chương trình THPT
- **Độ tuổi 15-18**: Phù hợp với giao diện và tính năng
- **Mục tiêu**: Cải thiện kết quả học tập, chuẩn bị thi đại học

### 👨‍🏫 Giáo Viên (Tính Năng Tương Lai)
- **Theo dõi học sinh**: Xem tiến độ học tập của học sinh
- **Giao bài tập**: Tạo và giao bài tập cho học sinh
- **Phân tích**: Báo cáo thống kê lớp học

### 👨‍👩‍👧‍👦 Phụ Huynh (Tính Năng Tương Lai)
- **Theo dõi con**: Xem tiến độ học tập của con
- **Nhận thông báo**: Thông báo về bài tập và kỳ thi
- **Hỗ trợ học tập**: Gợi ý cách hỗ trợ con học tập

## 💡 Lợi Ích Cho Người Dùng

### 🎓 Học Sinh
- **Quản lý thời gian hiệu quả**: Không bỏ lỡ deadline
- **Tăng động lực học tập**: Hệ thống phần thưởng và thành tích
- **Cải thiện kết quả**: Theo dõi tiến độ và điều chỉnh phương pháp
- **Chuẩn bị thi cử**: Nhắc nhở và đếm ngược kỳ thi

### 🏫 Nhà Trường
- **Nâng cao chất lượng**: Học sinh có công cụ học tập tốt hơn
- **Theo dõi tiến độ**: Báo cáo thống kê học tập
- **Tăng tỷ lệ đỗ đại học**: Học sinh chuẩn bị tốt hơn

### 👨‍👩‍👧‍👦 Phụ Huynh
- **Yên tâm**: Biết con đang học tập có kế hoạch
- **Hỗ trợ hiệu quả**: Biết con cần hỗ trợ gì
- **Theo dõi tiến độ**: Xem kết quả học tập của con

## 🔮 Roadmap Phát Triển

### 📅 Giai Đoạn 1 (MVP)
- [x] Xác thực người dùng
- [x] Quản lý bài tập cơ bản
- [x] Lập kế hoạch học tập
- [x] Đếm ngược kỳ thi
- [x] Đồng bộ dữ liệu
- [x] Thống kê cơ bản

### 🚧 Giai Đoạn 2 (Nâng Cao)
- [ ] Hệ thống gamification (huy hiệu, điểm kinh nghiệm)
- [ ] Tính năng xã hội (chia sẻ thành tích)
- [ ] Thông báo đẩy thông minh
- [ ] Phân tích nâng cao
- [ ] Tài liệu học tập
- [ ] Mục tiêu học tập

### 🌟 Giai Đoạn 3 (Mở Rộng)
- [ ] Tính năng cho giáo viên
- [ ] Tính năng cho phụ huynh
- [ ] Tích hợp AI (gợi ý học tập)
- [ ] Học trực tuyến
- [ ] Cộng đồng học tập
- [ ] Marketplace tài liệu

## 🛠 Công Nghệ Sử Dụng

### Giao Diện Người Dùng
- **Flutter 3.16.0**: Framework đa nền tảng
- **Dart 3.2.0**: Ngôn ngữ lập trình
- **Material Design 3**: Hệ thống thiết kế UI/UX
- **Riverpod**: Quản lý trạng thái
- **GoRouter**: Điều hướng

### Hệ Thống Backend & Dịch Vụ
- **Firebase Firestore**: Cơ sở dữ liệu NoSQL
- **Firebase Auth**: Xác thực người dùng
- **Firebase Analytics**: Phân tích hành vi người dùng
- **Firebase Crashlytics**: Báo cáo lỗi
- **Firebase Performance**: Giám sát hiệu suất
- **Firebase Cloud Messaging**: Thông báo đẩy

### Lưu Trữ Cục Bộ
- **SQLite**: Cơ sở dữ liệu cục bộ
- **SharedPreferences**: Lưu trữ cài đặt
- **Hive**: Lưu trữ NoSQL cục bộ

### Công Cụ Phát Triển
- **Android Studio / VS Code**: Môi trường phát triển
- **Git**: Quản lý phiên bản
- **GitHub Actions**: Tự động hóa CI/CD
- **Flutter Test**: Framework kiểm thử

## 🚀 Hướng Dẫn Cài Đặt

### Yêu Cầu Hệ Thống

#### Phát Triển
- **Flutter SDK**: 3.16.0 trở lên
- **Dart SDK**: 3.2.0 trở lên
- **Android Studio**: 2023.1+ hoặc VS Code
- **Git**: 2.30+
- **Node.js**: 18+ (cho Firebase CLI)

#### Chạy Ứng Dụng
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **RAM**: 2GB+
- **Bộ nhớ**: 100MB+

### Bước 1: Sao Chép Dự Án

```bash
git clone https://github.com/your-username/studybuddy.git
cd studybuddy
```

### Bước 2: Cài Đặt Thư Viện

```bash
flutter pub get
```

### Bước 3: Cấu Hình Firebase

#### 3.1 Tạo Dự Án Firebase
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo dự án mới: `studybuddy-app`
3. Bật các dịch vụ:
   - Authentication (Email/Mật khẩu, Google)
   - Firestore Database
   - Analytics
   - Crashlytics
   - Performance Monitoring
   - Cloud Messaging

#### 3.2 Cấu Hình Android
1. Thêm ứng dụng Android với package: `com.studybuddy.app`
2. Tải `google-services.json` vào `android/app/`
3. Cập nhật `android/build.gradle`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
```

#### 3.3 Cấu Hình iOS
1. Thêm ứng dụng iOS với bundle ID: `com.studybuddy.app`
2. Tải `GoogleService-Info.plist` vào `ios/Runner/`
3. Cài đặt Firebase pods:
```bash
cd ios
pod install
```

### Bước 4: Cấu Hình Môi Trường

#### 4.1 Tạo File Cấu Hình
```bash
cp lib/core/config/app_config.dart.example lib/core/config/app_config.dart
```

#### 4.2 Cập Nhật Khóa Firebase
```dart
// lib/core/config/app_config.dart
static const String firebaseApiKey = 'your-firebase-api-key';
static const String firebaseAppId = 'your-firebase-app-id';
static const String firebaseMessagingSenderId = 'your-sender-id';
```

### Bước 5: Chạy Ứng Dụng

#### Chế Độ Phát Triển
```bash
flutter run
```

#### Build Sản Xuất
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 Cấu Hình Phát Triển

### Biến Môi Trường

Tạo file `.env` trong thư mục gốc:
```env
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_SENDER_ID=your_sender_id
```

### Cấu Hình Debug

```dart
// lib/core/config/app_config.dart
static const bool enableDebugLogs = kDebugMode;
static const bool enableCrashlytics = !kDebugMode;
static const bool enablePerformanceMonitoring = !kDebugMode;
```

### Cờ Tính Năng

```dart
// lib/core/config/app_config.dart
static const bool enableGamification = false; // Giai đoạn 2
static const bool enableSocialFeatures = false; // Giai đoạn 2
static const bool enableAdvancedAnalytics = false; // Giai đoạn 2
static const bool enablePushNotifications = false; // Giai đoạn 2
```

## 🧪 Kiểm Thử

### Kiểm Thử Đơn Vị
```bash
flutter test
```

### Kiểm Thử Widget
```bash
flutter test test/widget_test.dart
```

### Kiểm Thử Tích Hợp
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Build & Triển Khai

### Build Android

#### Build Debug
```bash
flutter build apk --debug
```

#### Build Release
```bash
flutter build apk --release
flutter build appbundle --release
```

#### Cấu Hình Ký
1. Tạo keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Cấu hình ký trong `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        storeFile file("release.keystore")
        storePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

### Build iOS

#### Build Debug
```bash
flutter build ios --debug
```

#### Build Release
```bash
flutter build ios --release
```

#### Archive cho App Store
1. Mở Xcode
2. Product → Archive
3. Distribute App

### Triển Khai Firebase

#### Triển Khai Functions
```bash
firebase deploy --only functions
```

#### Triển Khai Hosting
```bash
firebase deploy --only hosting
```

## 🔍 Giám Sát & Phân Tích

### Firebase Analytics
- **Hành vi người dùng**: Theo dõi hành động người dùng
- **Xem màn hình**: Giám sát điều hướng màn hình
- **Sự kiện tùy chỉnh**: Số liệu kinh doanh cụ thể
- **Thuộc tính người dùng**: Phân khúc người dùng

### Firebase Crashlytics
- **Báo cáo sự cố**: Tự động phát hiện sự cố
- **Theo dõi lỗi**: Ghi log lỗi không nghiêm trọng
- **Ngữ cảnh người dùng**: Thông tin người dùng trong sự cố
- **Tác động hiệu suất**: Phân tích tác động sự cố

### Firebase Performance
- **Khởi động ứng dụng**: Giám sát thời gian khởi động
- **Tải màn hình**: Thời gian render màn hình
- **Gọi mạng**: Thời gian phản hồi API
- **Dấu vết tùy chỉnh**: Thời gian thao tác kinh doanh

## 🚀 Pipeline CI/CD

### Workflow GitHub Actions

Tạo file `.github/workflows/ci.yml`:

```yaml
name: Pipeline CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --debug

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-bundle
          path: build/app/outputs/bundle/release/app-release.aab
```

## 📱 Triển Khai App Store

### Google Play Store

#### 1. Tạo Tài Khoản Developer
- Truy cập [Google Play Console](https://play.google.com/console)
- Đăng ký tài khoản developer ($25)

#### 2. Chuẩn Bị App Bundle
```bash
flutter build appbundle --release
```

#### 3. Tải Lên Ứng Dụng
1. Tạo ứng dụng mới trong Play Console
2. Tải lên file AAB
3. Điền thông tin ứng dụng:
   - Tên ứng dụng: StudyBuddy
   - Mô tả ngắn: Ứng dụng học tập thông minh
   - Mô tả đầy đủ: Chi tiết tính năng
   - Ảnh chụp màn hình: Ảnh demo ứng dụng
   - Chính sách bảo mật: URL chính sách bảo mật

#### 4. Xếp Hạng Nội Dung
- Hoàn thành bảng câu hỏi xếp hạng nội dung
- Chọn xếp hạng phù hợp (3+ hoặc 7+)

#### 5. Phát Hành
- Kiểm thử nội bộ → Kiểm thử đóng → Kiểm thử mở → Sản xuất

### Apple App Store

#### 1. Tạo Tài Khoản Developer
- Truy cập [Apple Developer](https://developer.apple.com)
- Đăng ký tài khoản developer ($99/năm)

#### 2. Chuẩn Bị Ứng Dụng
```bash
flutter build ios --release
```

#### 3. Archive & Tải Lên
1. Mở Xcode
2. Product → Archive
3. Distribute App → App Store Connect
4. Tải lên App Store Connect

#### 4. App Store Connect
1. Tạo ứng dụng mới
2. Điền thông tin ứng dụng
3. Tải lên ảnh chụp màn hình và metadata
4. Gửi để xem xét

## 🔧 Khắc Phục Sự Cố

### Vấn Đề Thường Gặp

#### Cấu Hình Firebase
```bash
# Kiểm tra cài đặt Firebase
flutter doctor
firebase projects:list
```

#### Lỗi Build
```bash
# Xóa và build lại
flutter clean
flutter pub get
flutter build apk --release
```

#### Vấn Đề Hiệu Suất
```bash
# Phân tích hiệu suất
flutter run --profile
flutter run --trace-startup
```

### Công Cụ Debug

#### Flutter Inspector
```bash
flutter run --debug
# Mở Flutter Inspector trong DevTools
```

#### Performance Profiler
```bash
flutter run --profile
# Mở tab Performance trong DevTools
```

#### Network Inspector
```bash
flutter run --debug
# Mở tab Network trong DevTools
```

## 📚 Tài Liệu API

### Dịch Vụ Firebase

#### Xác Thực
```dart
// Đăng nhập
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Đăng ký
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
```

#### Firestore
```dart
// Thêm document
await FirebaseFirestore.instance
  .collection('tasks')
  .add(taskData);

// Truy vấn documents
final snapshot = await FirebaseFirestore.instance
  .collection('tasks')
  .where('userId', isEqualTo: userId)
  .get();
```

#### Analytics
```dart
// Ghi sự kiện
await FirebaseAnalytics.instance.logEvent(
  name: 'task_added',
  parameters: {'subject': 'Math'},
);
```

### Cơ Sở Dữ Liệu Cục Bộ

#### Thao Tác SQLite
```dart
// Thêm
await database.insert('tasks', taskData);

// Truy vấn
final tasks = await database.query('tasks');

// Cập nhật
await database.update('tasks', taskData, where: 'id = ?', whereArgs: [id]);

// Xóa
await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
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
   git commit -m 'Thêm tính năng mới'
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

## 📞 Hỗ Trợ

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