# 🔥 KHẮC PHỤC VẤN ĐỀ FIREBASE TRONG APK

## 📋 **Vấn đề đã phát hiện:**

Dự án của bạn có cấu hình Firebase cơ bản đúng, nhưng có thể gặp vấn đề với **SHA-1 Certificate Fingerprint** khi build APK.

## 🔍 **Nguyên nhân chính:**

1. **SHA-1 Fingerprint chưa được đăng ký** trong Firebase Console
2. **APK Release** cần SHA-1 khác với Debug
3. **Thiết bị thật** cần test thay vì emulator

## 🛠️ **Cách khắc phục:**

### **Bước 1: Thêm SHA-1 vào Firebase Console**

1. Truy cập: https://console.firebase.google.com
2. Chọn project: **studybuddy-8bfaa**
3. Vào **Project Settings** > **General**
4. Trong phần **"Your apps"**, chọn **Android app**
5. Thêm SHA-1 fingerprint: `6E:53:35:6D:CD:81:5A:17:F5:29:1F:14:16:61:3C:D4:38:BD:E7:F8`
6. Tải xuống `google-services.json` mới
7. Thay thế file cũ trong `android/app/`

### **Bước 2: Clean và Rebuild**

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Hoặc build release APK
flutter build apk --release
```

### **Bước 3: Test trên thiết bị thật**

⚠️ **QUAN TRỌNG:** Test APK trên **thiết bị thật**, không phải emulator!

## 📱 **Các loại APK:**

### **Debug APK:**
- Dùng cho development
- SHA-1: `6E:53:35:6D:CD:81:5A:17:F5:29:1F:14:16:61:3C:D4:38:BD:E7:F8`
- Build: `flutter build apk --debug`

### **Release APK:**
- Dùng cho production
- Cần keystore riêng
- Build: `flutter build apk --release`

## 🔧 **Script tự động:**

Chạy script để tự động khắc phục:

```bash
# Windows
scripts\fix_firebase_apk.bat

# Hoặc chạy Python script
python scripts/fix_firebase_apk.py
```

## 🚨 **Lỗi thường gặp:**

### **1. "Firebase not initialized"**
- Kiểm tra `google-services.json` có đúng package name không
- Đảm bảo SHA-1 đã được thêm vào Firebase Console

### **2. "Permission denied"**
- Test trên thiết bị thật
- Kiểm tra quyền internet trong AndroidManifest.xml

### **3. "Network error"**
- Kiểm tra kết nối internet
- Đảm bảo Firebase project đang hoạt động

## 📊 **Kiểm tra cấu hình:**

```bash
# Chạy script kiểm tra
python scripts/fix_firebase_apk.py
```

## ✅ **Kết quả mong đợi:**

Sau khi khắc phục, Firebase sẽ hoạt động bình thường trong APK với:
- ✅ Authentication
- ✅ Firestore Database
- ✅ Cloud Storage
- ✅ Analytics
- ✅ Crashlytics

## 📞 **Hỗ trợ:**

Nếu vẫn gặp vấn đề, hãy:
1. Kiểm tra logs trong Android Studio
2. Test trên thiết bị thật khác
3. Xem logs Firebase Console
4. Kiểm tra network connectivity 