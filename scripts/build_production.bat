@echo off
echo ========================================
echo    StudyBuddy Production Build Script
echo ========================================
echo.

REM Kiểm tra Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter chưa được cài đặt!
    echo Vui lòng cài đặt Flutter từ https://flutter.dev
    pause
    exit /b 1
)

echo ✅ Flutter đã được cài đặt
echo.

REM Clean project
echo 🧹 Đang clean project...
flutter clean
if errorlevel 1 (
    echo ❌ Lỗi clean project
    pause
    exit /b 1
)

REM Get dependencies
echo 📦 Đang cài đặt dependencies...
flutter pub get
if errorlevel 1 (
    echo ❌ Lỗi cài đặt dependencies
    pause
    exit /b 1
)

REM Build web for production
echo 🚀 Đang build web cho production...
flutter build web --release --web-renderer html
if errorlevel 1 (
    echo ❌ Lỗi build web
    pause
    exit /b 1
)

echo.
echo ✅ Build production thành công!
echo 📁 Output: build/web/
echo.

REM Hỏi có muốn deploy không
set /p deploy="🚀 Có muốn deploy lên hosting không? (y/N): "
if /i "%deploy%"=="y" (
    echo.
    echo 📤 Đang deploy lên Firebase Hosting...
    
    REM Kiểm tra Firebase CLI
    firebase --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Firebase CLI chưa được cài đặt!
        echo Vui lòng cài đặt: npm install -g firebase-tools
        pause
        exit /b 1
    )
    
    REM Deploy to Firebase Hosting
    firebase deploy --only hosting
    if errorlevel 1 (
        echo ❌ Lỗi deploy Firebase Hosting
        pause
        exit /b 1
    )
    
    echo.
    echo 🎉 Deploy thành công!
    echo 🌐 Website: https://studybuddy-8bfaa.web.app
)

echo.
echo ========================================
echo    Build hoàn tất!
echo ========================================
pause 