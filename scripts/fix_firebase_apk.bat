@echo off
echo 🚀 KHẮC PHỤC VẤN ĐỀ FIREBASE APK
echo ================================================

echo.
echo 📋 SHA-1 FINGERPRINT CẦN THÊM VÀO FIREBASE CONSOLE:
echo 6E:53:35:6D:CD:81:5A:17:F5:29:1F:14:16:61:3C:D4:38:BD:E7:F8
echo.

echo 🔧 BƯỚC 1: Clean project...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Lỗi khi clean project
    pause
    exit /b 1
)

echo.
echo 🔧 BƯỚC 2: Get dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Lỗi khi get dependencies
    pause
    exit /b 1
)

echo.
echo 🔧 BƯỚC 3: Build APK debug...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ Lỗi khi build APK debug
    pause
    exit /b 1
)

echo.
echo ✅ BUILD THÀNH CÔNG!
echo.
echo 📱 APK debug đã được tạo tại: build/app/outputs/flutter-apk/app-debug.apk
echo.
echo ⚠️  LƯU Ý QUAN TRỌNG:
echo 1. Đảm bảo SHA-1 fingerprint đã được thêm vào Firebase Console
echo 2. Test APK trên thiết bị thật (không phải emulator)
echo 3. Nếu vẫn lỗi, hãy build release APK: flutter build apk --release
echo.
pause 