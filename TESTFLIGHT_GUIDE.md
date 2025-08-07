# 🍎 HƯỚNG DẪN BUILD VÀ UPLOAD TESTFLIGHT

## 📋 **Yêu cầu hệ thống:**

### **1. Hardware:**
- ✅ **Mac computer** (bắt buộc)
- ✅ **iOS device** hoặc **iOS Simulator**
- ✅ **Apple Developer Account** ($99/năm)

### **2. Software:**
- ✅ **Xcode** (phiên bản mới nhất)
- ✅ **Flutter** (đã cài đặt)
- ✅ **CocoaPods** (đã cài đặt)

## 🚀 **Bước 1: Chuẩn bị môi trường**

### **Kiểm tra Xcode:**
```bash
xcodebuild -version
```

### **Kiểm tra iOS devices:**
```bash
xcrun devicectl list devices
```

### **Kiểm tra Flutter iOS:**
```bash
flutter doctor
```

## 🔧 **Bước 2: Cấu hình Firebase cho iOS**

### **1. Tải GoogleService-Info.plist:**
1. Truy cập: https://console.firebase.google.com
2. Chọn project: **studybuddy-8bfaa**
3. Vào **Project Settings** > **General**
4. Trong phần **"Your apps"**, chọn **iOS app**
5. Tải xuống **GoogleService-Info.plist**
6. Đặt file vào: `ios/Runner/GoogleService-Info.plist`

### **2. Cấu hình iOS Bundle ID:**
- Mở file: `ios/Runner.xcodeproj/project.pbxproj`
- Tìm `PRODUCT_BUNDLE_IDENTIFIER`
- Đảm bảo là: `com.studybuddy.app`

## 🏗️ **Bước 3: Build iOS App**

### **Chạy script tự động:**
```bash
python scripts/build_ios_testflight.py
```

### **Hoặc build thủ công:**
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release
```

## 📦 **Bước 4: Tạo IPA file**

### **1. Tạo Archive:**
```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/ios/Runner.xcarchive \
  archive
```

### **2. Export IPA:**
```bash
xcodebuild -exportArchive \
  -archivePath build/ios/Runner.xcarchive \
  -exportPath build/ios/ \
  -exportOptionsPlist ios/ExportOptions.plist
```

## 🚀 **Bước 5: Upload TestFlight**

### **Cách 1: Sử dụng Xcode Organizer**
1. Mở **Xcode**
2. Chọn **Window** > **Organizer**
3. Chọn tab **"Archives"**
4. Chọn archive vừa tạo
5. Click **"Distribute App"**
6. Chọn **"App Store Connect"**
7. Chọn **"Upload"**
8. Điền thông tin và upload

### **Cách 2: Sử dụng Command Line**
```bash
# Upload trực tiếp
xcrun altool --upload-app \
  --type ios \
  --file build/ios/Runner.ipa \
  --username "your-apple-id@email.com" \
  --password "app-specific-password"
```

## 📱 **Bước 6: Kiểm tra TestFlight**

### **1. App Store Connect:**
1. Truy cập: https://appstoreconnect.apple.com
2. Chọn app **StudyBuddy**
3. Vào **TestFlight** tab
4. Kiểm tra build đã upload

### **2. TestFlight App:**
1. Tải **TestFlight** từ App Store
2. Nhập **invitation code** (nếu có)
3. Tải và test app

## ⚠️ **Lưu ý quan trọng:**

### **1. Code Signing:**
- Đảm bảo **Provisioning Profile** đúng
- **Certificate** phải hợp lệ
- **Bundle ID** phải khớp

### **2. Firebase Configuration:**
- **GoogleService-Info.plist** phải đúng
- **Bundle ID** trong Firebase phải khớp
- **SHA-1** cho iOS (nếu cần)

### **3. App Store Guidelines:**
- Tuân thủ **App Store Review Guidelines**
- Test kỹ trước khi submit
- Chuẩn bị **screenshots** và **metadata**

## 🔧 **Troubleshooting:**

### **Lỗi thường gặp:**

#### **1. "No provisioning profiles found"**
- Kiểm tra **Apple Developer Account**
- Tạo **Provisioning Profile** mới
- Cập nhật **Xcode** settings

#### **2. "Archive failed"**
- Clean project: `flutter clean`
- Update dependencies: `flutter pub get`
- Kiểm tra **iOS deployment target**

#### **3. "Upload failed"**
- Kiểm tra **Apple ID** và **password**
- Tạo **App-specific password**
- Kiểm tra **network connection**

## 📞 **Hỗ trợ:**

Nếu gặp vấn đề:
1. Kiểm tra **Xcode** logs
2. Xem **Flutter** doctor output
3. Kiểm tra **Firebase Console**
4. Tham khảo **Apple Developer Documentation**

---

**🎉 Chúc bạn build và upload TestFlight thành công!** 