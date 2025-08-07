# 🖥️ BUILD IOS TRÊN WINDOWS (KHÔNG CẦN MAC)

## 📋 **Tổng quan:**

Vì iOS chỉ có thể build trên macOS, bạn có các tùy chọn sau để build iOS từ Windows:

## 🚀 **Tùy chọn 1: GitHub Actions (Miễn phí)**

### **Bước 1: Tạo GitHub repository**
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/studybuddy.git
git push -u origin main
```

### **Bước 2: Tạo GitHub Actions workflow**
Tạo file `.github/workflows/ios.yml`:

```yaml
name: iOS Build
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
          channel: 'stable'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build iOS
        run: |
          flutter build ios --release
          xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/ios/Runner.xcarchive \
            archive
            
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/ios/Runner.xcarchive \
            -exportPath build/ios/ \
            -exportOptionsPlist ios/ExportOptions.plist
            
      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: ios-app
          path: build/ios/Runner.ipa
```

### **Bước 3: Push code**
```bash
git add .github/workflows/ios.yml
git commit -m "Add iOS build workflow"
git push
```

## 🔥 **Tùy chọn 2: Codemagic CI/CD**

### **Bước 1: Đăng ký Codemagic**
1. Truy cập: https://codemagic.io
2. Đăng ký với GitHub/GitLab account
3. Kết nối repository

### **Bước 2: Tạo codemagic.yaml**
```yaml
workflows:
  ios-workflow:
    name: iOS Workflow
    environment:
      xcode: latest
      cocoapods: default
      flutter: stable
    scripts:
      - name: Build iOS
        script: |
          flutter pub get
          flutter build ios --release
          xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/ios/Runner.xcarchive \
            archive
          xcodebuild -exportArchive \
            -archivePath build/ios/Runner.xcarchive \
            -exportPath build/ios/ \
            -exportOptionsPlist ios/ExportOptions.plist
    artifacts:
      - build/ios/Runner.ipa
      - build/ios/Runner.xcarchive
```

## 💻 **Tùy chọn 3: Remote Mac Services**

### **A. MacStadium**
- Giá: $0.50/giờ cho Mac mini
- Link: https://www.macstadium.com
- Hỗ trợ: Full Xcode, CI/CD

### **B. MacinCloud**
- Giá: Từ $1/giờ
- Link: https://www.macincloud.com
- Hỗ trợ: Dedicated Mac servers

### **C. Amazon EC2 Mac instances**
- Giá: $1.083/giờ
- Link: https://aws.amazon.com/ec2/instance-types/mac/
- Hỗ trợ: macOS Big Sur, Monterey

## 🔧 **Tùy chọn 4: Firebase App Distribution**

### **Bước 1: Cấu hình Firebase**
1. Truy cập: https://console.firebase.google.com
2. Chọn project: studybuddy-8bfaa
3. Vào App Distribution
4. Thêm iOS app

### **Bước 2: Tích hợp với CI/CD**
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Login Firebase
firebase login

# Cấu hình App Distribution
firebase appdistribution:groups:add testers test@example.com
```

## 📱 **Tùy chọn 5: Build iOS Framework trên Windows**

### **Bước 1: Build iOS Framework**
```bash
flutter build ios-framework --output=build/ios-framework
```

### **Bước 2: Sử dụng framework**
- Framework có thể dùng trong Xcode project
- Cần Mac để tạo IPA từ framework

## ⚠️ **Lưu ý quan trọng:**

### **1. Apple Developer Account**
- Cần Apple Developer Account ($99/năm) để upload TestFlight
- Không thể tránh được yêu cầu này

### **2. Code Signing**
- Cần Provisioning Profile và Certificate
- Có thể tạo trên Apple Developer Portal

### **3. Firebase iOS Configuration**
- Cần GoogleService-Info.plist
- Tải từ Firebase Console

## 🎯 **Khuyến nghị:**

### **Cho người mới:**
1. **GitHub Actions** (miễn phí)
2. **Firebase App Distribution** (miễn phí)

### **Cho dự án thương mại:**
1. **Codemagic** (tích hợp tốt)
2. **MacStadium** (ổn định)

### **Cho team lớn:**
1. **Remote Mac** (full control)
2. **AWS EC2 Mac** (scalable)

## 📞 **Hỗ trợ:**

Nếu gặp vấn đề:
1. Kiểm tra GitHub Actions logs
2. Xem Codemagic build logs
3. Kiểm tra Firebase Console
4. Tham khảo Apple Developer Documentation

---

**🎉 Với các tùy chọn trên, bạn có thể build iOS mà không cần Mac!** 