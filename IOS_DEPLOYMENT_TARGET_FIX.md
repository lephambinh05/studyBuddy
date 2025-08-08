# 🚨 LỖI IOS DEPLOYMENT TARGET VÀ GIẢI PHÁP

## 📋 **Lỗi mới phát hiện:**

```
Error: The plugin "cloud_firestore" requires a higher minimum iOS deployment version than your application is targeting.
To build, increase your application's deployment target to at least 15.0 as described at https://flutter.dev/to/ios-deploy
```

## 🔍 **Nguyên nhân:**

**cloud_firestore** yêu cầu iOS deployment target **15.0** trở lên, nhưng project đang sử dụng **13.0**.

## 🔧 **Giải pháp đã áp dụng:**

### **1. Cập nhật Podfile**
```ruby
# Từ:
platform :ios, '13.0'

# Thành:
platform :ios, '15.0'
```

### **2. Cập nhật project.pbxproj**
```bash
# Thay thế tất cả:
IPHONEOS_DEPLOYMENT_TARGET = 13.0;

# Thành:
IPHONEOS_DEPLOYMENT_TARGET = 15.0;
```

### **3. Cập nhật Codemagic config**
```yaml
# Cập nhật workflow name
name: iOS Build (iOS 15.0)
```

## 📊 **Firebase iOS Requirements:**

| Package | iOS Requirement |
|---------|----------------|
| firebase_core | iOS 12.0+ |
| firebase_auth | iOS 12.0+ |
| **cloud_firestore** | **iOS 15.0+** |
| firebase_storage | iOS 12.0+ |

## 🚨 **Breaking Change:**

Đây là **breaking change** từ Firebase SDK 12.0.0:
- cloud_firestore trước đây: iOS 12.0+
- cloud_firestore hiện tại: iOS 15.0+

## 📱 **Impact trên iOS Devices:**

### **iOS 15.0+ Coverage:**
- iPhone 6s/6s Plus trở lên
- iPad Air 2 trở lên
- iPad mini 4 trở lên
- iPod touch 7th generation

### **Devices bị loại trừ:**
- iPhone 6/6 Plus (iOS 12.5.7 max)
- iPad Air 1 (iOS 12.5.7 max)
- iPad mini 3 (iOS 12.5.7 max)

## 🔧 **Files đã được cập nhật:**

1. **ios/Podfile** - Platform và deployment target
2. **ios/Runner.xcodeproj/project.pbxproj** - Tất cả deployment targets
3. **codemagic.yaml** - Workflow name

## 📋 **Checklist hoàn thành:**

- [x] Fix Podfile platform
- [x] Fix Podfile deployment target
- [x] Fix project.pbxproj deployment targets
- [x] Update Codemagic config
- [ ] Test trên Codemagic
- [ ] Verify iOS device compatibility

## 🚀 **Bước tiếp theo:**

```bash
git add .
git commit -m 'Fix iOS deployment target to 15.0 for cloud_firestore'
git push origin main
```

## 💡 **Kết luận:**

Lỗi này xảy ra do **breaking change** từ Firebase SDK 12.0.0. cloud_firestore giờ yêu cầu iOS 15.0+, trong khi project đang target iOS 13.0. Đã fix bằng cách update deployment target lên 15.0.

## ⚠️ **Lưu ý:**

- App sẽ không chạy trên iOS devices cũ hơn 15.0
- Cần test trên iOS 15.0+ devices
- Có thể cần update marketing materials 