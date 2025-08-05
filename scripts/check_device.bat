@echo off
echo 🔍 KIỂM TRA THIẾT BỊ VÀ FIREBASE
echo ================================================

echo.
echo 📱 Kiểm tra thiết bị kết nối...
flutter devices

echo.
echo 📊 Kiểm tra APK đã cài đặt...
adb shell pm list packages | findstr studybuddy

echo.
echo 🔧 Kiểm tra log Firebase...
echo Để xem log chi tiết, chạy: flutter run --device-id=N0AA003668K52601992 -v

echo.
echo 📋 HƯỚNG DẪN TEST FIREBASE:
echo 1. Mở app StudyBuddy trên thiết bị
echo 2. Thử đăng nhập/đăng ký
echo 3. Thử tạo task mới
echo 4. Kiểm tra notification
echo 5. Xem log trong Firebase Console

echo.
echo 🔗 Firebase Console: https://console.firebase.google.com/project/studybuddy-8bfaa
echo.

pause 