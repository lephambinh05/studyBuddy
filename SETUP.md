# 🚀 Hướng Dẫn Cài Đặt & Chạy StudyBuddy

## 📋 Yêu Cầu Hệ Thống

### Phát Triển
- **Flutter SDK**: 3.16.0 trở lên
- **Dart SDK**: 3.2.0 trở lên
- **Android Studio** 2023.1+ hoặc **VS Code**
- **Git**: 2.30+
- **Node.js**: 18+ (cho Firebase CLI)

### Chạy Ứng Dụng
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **RAM**: 2GB+
- **Bộ nhớ**: 100MB+

## 🔧 Cài Đặt

### Bước 1: Cài Đặt Flutter

1. **Tải Flutter SDK**:
   ```bash
   # Windows
   # Tải từ: https://flutter.dev/docs/get-started/install/windows
   
   # macOS
   brew install flutter
   
   # Linux
   sudo snap install flutter --classic
   ```

2. **Kiểm tra cài đặt**:
   ```bash
   flutter doctor
   ```

3. **Cài đặt Android Studio** (cho Android development):
   - Tải từ: https://developer.android.com/studio
   - Cài đặt Android SDK
   - Cấu hình ANDROID_HOME

### Bước 2: Clone Repository

```bash
git clone https://github.com/your-username/studybuddy.git
cd studybuddy
```

### Bước 3: Cài Đặt Dependencies

```bash
flutter pub get
```

### Bước 4: Cấu Hình Firebase (Tùy Chọn)

#### 4.1 Tạo Dự Án Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo dự án mới: `studybuddy-app`
3. Bật các dịch vụ:
   - Authentication (Email/Mật khẩu, Google)
   - Firestore Database
   - Analytics
   - Crashlytics
   - Performance Monitoring
   - Cloud Messaging

#### 4.2 Cấu Hình Android

1. Thêm ứng dụng Android với package: `com.studybuddy.app`
2. Tải `google-services.json` vào `android/app/`
3. Cập nhật `android/build.gradle`:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
   ```

#### 4.3 Cấu Hình iOS

1. Thêm ứng dụng iOS với bundle ID: `com.studybuddy.app`
2. Tải `GoogleService-Info.plist` vào `ios/Runner/`
3. Cài đặt Firebase pods:
   ```bash
   cd ios
   pod install
   ```

#### 4.4 Cập Nhật Firebase Config

Cập nhật `lib/main.dart` với thông tin Firebase của bạn:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id",
  ),
);
```

## 🚀 Chạy Ứng Dụng

### Chế Độ Phát Triển

```bash
# Chạy trên thiết bị được kết nối
flutter run

# Chạy trên web
flutter run -d chrome

# Chạy trên Android emulator
flutter run -d android

# Chạy trên iOS simulator
flutter run -d ios
```

### Build Sản Xuất

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📱 Cấu Hình Thiết Bị

### Android

1. **Bật Developer Options**:
   - Vào Settings > About phone
   - Tap "Build number" 7 lần
   - Bật "USB debugging"

2. **Kết nối thiết bị**:
   ```bash
   adb devices
   ```

### iOS

1. **Cài đặt Xcode** (macOS only)
2. **Kết nối iPhone**:
   - Tin tưởng máy tính
   - Bật Developer mode

## 🔧 Cấu Hình Môi Trường

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

## 🧪 Testing

### Unit Tests

```bash
# Chạy tất cả unit tests
flutter test

# Chạy test cụ thể
flutter test test/unit/task_repository_test.dart

# Chạy với coverage
flutter test --coverage
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

### iOS

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

### Web

#### Build cho Production
```bash
flutter build web --release
```

#### Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

## 🔍 Debug & Troubleshooting

### Lỗi Thường Gặp

#### 1. Flutter Doctor Issues
```bash
# Cài đặt Android SDK
flutter doctor --android-licenses

# Cài đặt Xcode Command Line Tools
xcode-select --install
```

#### 2. Firebase Issues
```bash
# Kiểm tra cài đặt Firebase
flutter doctor
firebase projects:list
```

#### 3. Build Issues
```bash
# Xóa và build lại
flutter clean
flutter pub get
flutter build apk --release
```

#### 4. Performance Issues
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

## 📚 Tài Liệu Tham Khảo

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Flutter Samples](https://github.com/flutter/samples)

### Firebase
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

### Material Design
- [Material Design 3](https://m3.material.io/)
- [Flutter Material Components](https://api.flutter.dev/flutter/material/material-library.html)

## 🤝 Hỗ Trợ

### Cộng Đồng
- **Stack Overflow**: [flutter] tag
- **Reddit**: r/FlutterDev
- **Discord**: Flutter Community

### Tài Liệu Dự Án
- [README.md](README.md) - Tổng quan dự án
- [CHANGELOG.md](CHANGELOG.md) - Lịch sử thay đổi
- [CONTRIBUTING.md](CONTRIBUTING.md) - Hướng dẫn đóng góp

---

**Chúc bạn phát triển thành công! 🚀** 