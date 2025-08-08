#!/usr/bin/env python3
"""
Script fix tất cả settings về iOS 15.0 minimum
"""

import os
import re
import subprocess
import sys

def fix_podfile_ios15():
    """Fix Podfile với iOS 15.0 minimum"""
    print("🔧 Fixing Podfile with iOS 15.0 minimum...")
    
    podfile_path = 'ios/Podfile'
    
    with open(podfile_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Cập nhật platform và deployment target
    content = re.sub(r"platform :ios, '.*?'", "platform :ios, '15.0'", content)
    content = re.sub(r"IPHONEOS_DEPLOYMENT_TARGET = '.*?'", "IPHONEOS_DEPLOYMENT_TARGET = '15.0'", content)
    
    with open(podfile_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Podfile đã được cập nhật với iOS 15.0 minimum")

def fix_project_pbxproj_ios15():
    """Fix project.pbxproj với iOS 15.0 minimum"""
    print("🔧 Fixing project.pbxproj with iOS 15.0 minimum...")
    
    pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
    
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Cập nhật tất cả IPHONEOS_DEPLOYMENT_TARGET thành 15.0
    content = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = \d+\.\d+;', 'IPHONEOS_DEPLOYMENT_TARGET = 15.0;', content)
    
    # Thêm settings cần thiết cho iOS 15.0
    build_settings = {
        'SUPPORTED_PLATFORMS': 'iphoneos',
        'SDKROOT': 'iphoneos',
        'VALIDATE_PRODUCT': 'YES',
        'TARGETED_DEVICE_FAMILY': '"1,2"',
        'IPHONEOS_DEPLOYMENT_TARGET': '15.0',
        'GCC_C_LANGUAGE_STANDARD': 'gnu11',
        'CLANG_CXX_LANGUAGE_STANDARD': 'c++14',
        'CLANG_CXX_LIBRARY': 'libc++',
        'ENABLE_BITCODE': 'NO',
        'SWIFT_VERSION': '5.0',
        'CLANG_ENABLE_MODULES': 'YES',
        'CLANG_ENABLE_OBJC_ARC': 'YES',
        'GCC_OPTIMIZATION_LEVEL': '0',
        'SWIFT_OPTIMIZATION_LEVEL': '-Onone'
    }
    
    # Tìm và cập nhật tất cả build configurations
    build_config_pattern = r'(buildSettings = \{[\s\S]*?\};)'
    
    def update_build_settings(match):
        settings_block = match.group(1)
        
        # Thêm tất cả settings cần thiết
        for key, value in build_settings.items():
            # Kiểm tra xem setting đã tồn tại chưa
            if f'{key} = ' not in settings_block:
                # Thêm vào cuối settings block
                settings_block = settings_block.replace('};', f'\t\t\t\t\t{key} = {value};\n\t\t\t\t}};')
        
        return f'buildSettings = {settings_block}'
    
    # Cập nhật tất cả build configurations
    updated_content = re.sub(build_config_pattern, update_build_settings, content)
    
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj đã được cập nhật với iOS 15.0 minimum")

def create_codemagic_ios15():
    """Tạo codemagic.yaml với iOS 15.0 minimum"""
    print("🔧 Creating codemagic.yaml with iOS 15.0 minimum...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (iOS 15.0 Minimum)
    environment:
      xcode: 14.3
      cocoapods: default
    scripts:
      - name: Setup
        script: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          flutter clean
      - name: Install pods
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS Framework
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
    
    print("✅ codemagic.yaml đã được tạo với iOS 15.0 minimum")

def create_full_ios_workflow_ios15():
    """Tạo full iOS workflow với iOS 15.0 minimum"""
    print("🔧 Creating full iOS workflow with iOS 15.0 minimum...")
    
    full_ios_content = """workflows:
  ios-full-workflow:
    name: iOS Full Build (iOS 15.0 Minimum)
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
      - name: Setup
        script: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          flutter clean
      - name: Install pods
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
    
    with open('codemagic_full_ios_ios15.yaml', 'w') as f:
        f.write(full_ios_content)
    
    print("✅ codemagic_full_ios_ios15.yaml đã được tạo")

def create_guide_ios15():
    """Tạo hướng dẫn iOS 15.0 minimum"""
    print("🔧 Creating iOS 15.0 minimum guide...")
    
    guide_content = """# 🚀 iOS 15.0 MINIMUM DEPLOYMENT TARGET

## 📋 **Cấu hình hiện tại:**

### **iOS Deployment Target: 15.0**
- **Podfile**: `platform :ios, '15.0'`
- **project.pbxproj**: `IPHONEOS_DEPLOYMENT_TARGET = 15.0`
- **Codemagic**: Xcode 14.3 + iOS 15.0

## 🔧 **Lý do chọn iOS 15.0:**

### **Compatibility:**
- ✅ **Firebase**: cloud_firestore yêu cầu iOS 15.0+
- ✅ **Modern APIs**: Sử dụng được các API mới nhất
- ✅ **Performance**: Tối ưu cho iOS 15.0+
- ✅ **Security**: Bảo mật tốt hơn

### **Device Support:**
- **iPhone**: iPhone 6s trở lên (iOS 15.0+)
- **iPad**: iPad Air 2 trở lên (iOS 15.0+)
- **Coverage**: ~95% thiết bị iOS hiện tại

## 📱 **Workflows có sẵn:**

| File | iOS Target | Build Type | Mục đích |
|------|------------|------------|----------|
| **codemagic.yaml** | 15.0 | Framework | Mặc định |
| **codemagic_full_ios_ios15.yaml** | 15.0 | Full iOS | TestFlight |

## ⚠️ **Lưu ý quan trọng:**

### **Device Compatibility:**
- App chỉ chạy trên **iOS 15.0+**
- Không hỗ trợ **iOS 14.x** trở xuống
- **iPhone 6s+** và **iPad Air 2+** được hỗ trợ

### **User Impact:**
- **~5%** users có thể không cài được app
- **~95%** users có thể sử dụng bình thường
- **Trade-off** giữa features và compatibility

## 🔍 **Test Steps:**

1. **Build test** với iOS 15.0
2. **Device test** trên iOS 15.0+
3. **TestFlight** deployment
4. **User feedback** về compatibility

## 🎯 **Expected Result:**

- ✅ Build thành công với iOS 15.0
- ✅ Không còn lỗi deployment target
- ✅ Firebase hoạt động bình thường
- ✅ TestFlight deployment thành công
- ✅ App chạy tốt trên iOS 15.0+
"""
    
    with open('IOS_15_MINIMUM_GUIDE.md', 'w') as f:
        f.write(guide_content)
    
    print("✅ IOS_15_MINIMUM_GUIDE.md đã được tạo")

def main():
    """Main function"""
    print("🚀 FIXING iOS 15.0 MINIMUM DEPLOYMENT TARGET")
    print("=" * 60)
    
    print("\n📋 Cấu hình:")
    print("1. iOS Deployment Target: 15.0")
    print("2. Firebase compatibility: ✅")
    print("3. Device coverage: ~95%")
    print("4. Modern APIs: ✅")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix Podfile
    fix_podfile_ios15()
    
    # Fix project.pbxproj
    fix_project_pbxproj_ios15()
    
    # Create codemagic configs
    create_codemagic_ios15()
    create_full_ios_workflow_ios15()
    
    # Create guide
    create_guide_ios15()
    
    print("\n" + "=" * 60)
    print("✅ TẤT CẢ iOS 15.0 FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix iOS 15.0 minimum deployment target'")
    print("   git push origin main")
    print("\n2. Trong Codemagic Dashboard:")
    print("   - Thay đổi Xcode version thành '14.3'")
    print("   - Test build với iOS 15.0")
    print("\n3. Test device compatibility:")
    print("   - iOS 15.0+ devices")
    print("   - TestFlight deployment")
    
    print("\n🔍 Workflows:")
    print("- codemagic.yaml: Framework build (iOS 15.0)")
    print("- codemagic_full_ios_ios15.yaml: Full iOS + TestFlight")

if __name__ == "__main__":
    main() 