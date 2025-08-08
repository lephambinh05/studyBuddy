#!/usr/bin/env python3
"""
Script tự động fix Xcode version trong Codemagic config
"""

import os
import re
import subprocess
import sys

def auto_fix_codemagic_xcode():
    """Tự động fix Xcode version trong Codemagic"""
    print("🔧 Auto fixing Xcode version in Codemagic config...")
    
    # Cập nhật codemagic.yaml với Xcode 14.3
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Framework Build (Xcode 14.3 - Auto Fixed)
    environment:
      xcode: 14.3
      cocoapods: default
    scripts:
      - name: Get Flutter packages
        script: flutter pub get
      - name: Generate code
        script: |
          flutter pub run build_runner clean
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean iOS build
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          rm -rf .symlinks/
          flutter clean
      - name: Install iOS dependencies
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS Framework Only
        script: |
          flutter build ios-framework --output=build/ios-framework
    artifacts:
      - build/ios-framework/
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: false
"""
    
    with open('codemagic.yaml', 'w') as f:
        f.write(codemagic_content)
    
    print("✅ codemagic.yaml đã được cập nhật với Xcode 14.3")

def create_full_ios_workflow():
    """Tạo full iOS workflow với Xcode 14.3"""
    print("🔧 Creating full iOS workflow with Xcode 14.3...")
    
    full_ios_content = """workflows:
  ios-full-workflow:
    name: iOS Full Build (Xcode 14.3 - TestFlight)
    environment:
      xcode: 14.3
      cocoapods: default
      vars:
        XCODE_WORKSPACE: "ios/Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
    scripts:
      - name: Set up code signing settings
        script: |
          keychain initialize
          app-store-connect fetch-signing-files "com.studybuddy.app" --type IOS_APP_STORE --create
          keychain add-certificates
          xcode-project use-profiles
      - name: Get Flutter packages
        script: flutter pub get
      - name: Generate code
        script: |
          flutter pub run build_runner clean
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean iOS build
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          rm -rf .symlinks/
          flutter clean
      - name: Install iOS dependencies
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS
        script: |
          flutter build ios --release --no-codesign
          xcode-project build-ipa --workspace ios/Runner.xcworkspace --scheme Runner
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
"""
    
    with open('codemagic_full_ios_xcode14.yaml', 'w') as f:
        f.write(full_ios_content)
    
    print("✅ codemagic_full_ios_xcode14.yaml đã được tạo")

def create_debug_workflow():
    """Tạo debug workflow với Xcode 14.3"""
    print("🔧 Creating debug workflow with Xcode 14.3...")
    
    debug_content = """workflows:
  ios-debug-workflow:
    name: iOS Debug Build (Xcode 14.3)
    environment:
      xcode: 14.3
      cocoapods: default
    scripts:
      - name: Setup
        script: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean iOS
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          flutter clean
      - name: Install pods
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS Debug
        script: |
          flutter build ios --debug --no-codesign
    artifacts:
      - build/ios/
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: false
"""
    
    with open('codemagic_debug_xcode14.yaml', 'w') as f:
        f.write(debug_content)
    
    print("✅ codemagic_debug_xcode14.yaml đã được tạo")

def create_guide():
    """Tạo hướng dẫn sử dụng"""
    print("🔧 Creating usage guide...")
    
    guide_content = """# 🚀 HƯỚNG DẪN TỰ ĐỘNG FIX XCODE VERSION

## 📋 **Vấn đề đã được xác định:**

Trong Codemagic dashboard, Xcode version đang là:
```
Xcode version: Latest (16.4)
```

**Xcode 16.4** gây ra lỗi:
```
Error (Xcode): Failed to parse Target Device Version
```

## 🔧 **Giải pháp tự động:**

### **1. Workflows đã được tạo:**

| File | Xcode Version | Build Type | Mục đích |
|------|---------------|------------|----------|
| **codemagic.yaml** | 14.3 | Framework | Mặc định |
| **codemagic_full_ios_xcode14.yaml** | 14.3 | Full iOS | TestFlight |
| **codemagic_debug_xcode14.yaml** | 14.3 | Debug | Test |

### **2. Cách sử dụng:**

#### **Bước 1: Push code**
```bash
git add .
git commit -m 'Auto fix Xcode version to 14.3'
git push origin main
```

#### **Bước 2: Trong Codemagic Dashboard**
1. Vào **Workflow Editor**
2. Thay đổi **Xcode version** từ **"Latest (16.4)"** thành **"14.3"**
3. Hoặc sử dụng **Switch to YAML configuration**
4. Copy nội dung từ `codemagic.yaml`

#### **Bước 3: Test build**
- Chạy build với Xcode 14.3
- Kiểm tra xem lỗi Target Device Version có còn không

## 🎯 **Lý do chọn Xcode 14.3:**

- **Stability**: Ổn định hơn Xcode 16.4
- **Compatibility**: Tương thích tốt với iOS 15.0
- **Testing**: Được test rộng rãi
- **Community**: Nhiều developers sử dụng

## ⚠️ **Lưu ý:**

- **Xcode 16.4** có thể là beta version
- **Xcode 14.3** ổn định cho production
- **Framework-only build** giảm risk
- **Full iOS build** cho TestFlight

## 🔍 **Debug Steps:**

1. **Thay đổi Xcode version** trong Codemagic dashboard
2. **Test framework build** trước
3. **Test full iOS build** nếu cần TestFlight
4. **Manual build** nếu vẫn lỗi
"""
    
    with open('AUTO_FIX_XCODE_GUIDE.md', 'w') as f:
        f.write(guide_content)
    
    print("✅ AUTO_FIX_XCODE_GUIDE.md đã được tạo")

def main():
    """Main function"""
    print("🚀 AUTO FIX XCODE VERSION IN CODEMAGIC")
    print("=" * 60)
    
    print("\n📋 Vấn đề đã được xác định:")
    print("1. Codemagic dashboard: Xcode Latest (16.4)")
    print("2. Lỗi: 'Failed to parse Target Device Version'")
    print("3. Cần thay đổi thành Xcode 14.3")
    
    print("\n🔧 Thực hiện auto fixes...")
    
    # Auto fix Codemagic config
    auto_fix_codemagic_xcode()
    
    # Create full iOS workflow
    create_full_ios_workflow()
    
    # Create debug workflow
    create_debug_workflow()
    
    # Create guide
    create_guide()
    
    print("\n" + "=" * 60)
    print("✅ TẤT CẢ AUTO FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Auto fix Xcode version to 14.3'")
    print("   git push origin main")
    print("\n2. Trong Codemagic Dashboard:")
    print("   - Vào Workflow Editor")
    print("   - Thay đổi Xcode version từ 'Latest (16.4)' thành '14.3'")
    print("   - Hoặc sử dụng Switch to YAML configuration")
    print("\n3. Test build với Xcode 14.3")
    
    print("\n🔍 Alternative workflows:")
    print("- codemagic.yaml: Framework build (mặc định)")
    print("- codemagic_full_ios_xcode14.yaml: Full iOS + TestFlight")
    print("- codemagic_debug_xcode14.yaml: Debug build")

if __name__ == "__main__":
    main() 