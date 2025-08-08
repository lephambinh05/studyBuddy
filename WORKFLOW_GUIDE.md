# 📋 HƯỚNG DẪN SỬ DỤNG WORKFLOWS

## 🚀 **Workflows có sẵn:**

### **1. codemagic.yaml (Mặc định)**
```yaml
# iOS Framework Build (Simple)
# ✅ Khuyến nghị sử dụng
# 🎯 Mục đích: Build framework only, tránh lỗi Target Device Version
# 📦 Output: build/ios-framework/
# 🚫 TestFlight: Không
```

### **2. codemagic_full_ios.yaml**
```yaml
# iOS Full Build (TestFlight)
# ⚠️ Có thể gặp lỗi Target Device Version
# 🎯 Mục đích: Full iOS build với TestFlight
# 📦 Output: build/ios/ipa/*.ipa
# ✅ TestFlight: Có
```

### **3. codemagic_simple.yaml**
```yaml
# iOS Simple Build
# 🎯 Mục đích: Framework only, không clean
# 📦 Output: build/ios-framework/
# 🚫 TestFlight: Không
```

### **4. codemagic_debug.yaml**
```yaml
# iOS Debug Build
# 🎯 Mục đích: Debug build
# 📦 Output: build/ios/
# 🚫 TestFlight: Không
```

### **5. codemagic_simple_test.yaml**
```yaml
# iOS Simple Build (Test)
# 🎯 Mục đích: Test build với clean
# 📦 Output: build/ios-framework/
# 🚫 TestFlight: Không
```

## 🔧 **Cách sử dụng:**

### **Bước 1: Chọn workflow**
```bash
# Mặc định (Framework only - Khuyến nghị)
codemagic.yaml

# Hoặc Full iOS build (Có thể lỗi)
codemagic_full_ios.yaml
```

### **Bước 2: Push code**
```bash
git add .
git commit -m 'Update workflow'
git push origin main
```

### **Bước 3: Test trên Codemagic**
- Vào Codemagic dashboard
- Chọn project
- Chạy build với workflow đã chọn

## 📊 **So sánh workflows:**

| Workflow | Build Type | TestFlight | Risk | Speed |
|----------|------------|------------|------|-------|
| **codemagic.yaml** | Framework | ❌ | 🟢 Low | ⚡ Fast |
| **codemagic_full_ios.yaml** | Full iOS | ✅ | 🔴 High | 🐌 Slow |
| **codemagic_simple.yaml** | Framework | ❌ | 🟢 Low | ⚡ Fast |
| **codemagic_debug.yaml** | Debug | ❌ | 🟡 Medium | ⚡ Fast |
| **codemagic_simple_test.yaml** | Framework | ❌ | 🟢 Low | ⚡ Fast |

## 🎯 **Khuyến nghị:**

### **Cho Development:**
```yaml
# Sử dụng codemagic.yaml
# Framework only, nhanh, ít lỗi
```

### **Cho Production (TestFlight):**
```yaml
# Thử codemagic_full_ios.yaml
# Nếu lỗi, dùng manual build
```

## 🚨 **Lỗi Target Device Version:**

### **Nguyên nhân:**
- Xcode version không tương thích
- Build settings conflict
- Device targeting issues

### **Giải pháp:**
1. **Sử dụng framework-only build** (codemagic.yaml)
2. **Manual build** trên máy local
3. **Update Xcode version** trên Codemagic

## 📱 **Manual Build cho TestFlight:**

Nếu Codemagic vẫn lỗi, build manual:

```bash
# 1. Clean
flutter clean
cd ios && pod install && cd ..

# 2. Build
flutter build ios --release

# 3. Archive trong Xcode
# 4. Upload lên App Store Connect
```

## ⚠️ **Lưu ý:**

- **Framework-only build** không tạo IPA file
- **Full iOS build** có thể gặp lỗi Target Device Version
- **TestFlight** chỉ có với full iOS build
- **Manual build** là giải pháp cuối cùng 