#!/usr/bin/env python3
"""
Script fix cuối cùng cho Target Device Version error
"""

import os
import re
import subprocess
import sys

def fix_project_pbxproj():
    """Fix project.pbxproj với settings đầy đủ"""
    print("🔧 Fixing project.pbxproj with comprehensive settings...")
    
    pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
    
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Thêm settings cần thiết cho tất cả build configurations
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
    
    print("✅ project.pbxproj đã được cập nhật với comprehensive settings")

def create_simple_codemagic():
    """Tạo codemagic.yaml đơn giản nhất"""
    print("🔧 Creating simplest codemagic.yaml...")
    
    simple_content = """workflows:
  ios-workflow:
    name: iOS Simple Build (Xcode 14.3)
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
        f.write(simple_content)
    
    print("✅ codemagic.yaml đã được tạo với cấu hình đơn giản nhất")

def create_manual_guide():
    """Tạo hướng dẫn manual fix"""
    print("🔧 Creating manual fix guide...")
    
    guide_content = """# 🚨 MANUAL FIX FOR TARGET DEVICE VERSION ERROR

## 📋 **Vấn đề hiện tại:**
```
Error (Xcode): Failed to parse Target Device Version
```

## 🔧 **Giải pháp MANUAL (Bắt buộc):**

### **Bước 1: Trong Codemagic Dashboard**
1. Vào **Workflow Editor**
2. Tìm **Environment** section
3. Thay đổi **Xcode version** từ **"Latest (16.4)"** thành **"14.3"**
4. **Save** changes

### **Bước 2: Alternative - Switch to YAML**
1. Trong Workflow Editor, click **"Switch to YAML configuration"**
2. Copy nội dung từ `codemagic.yaml` trong repo
3. **Save** changes

### **Bước 3: Test Build**
1. Chạy build với Xcode 14.3
2. Kiểm tra log xem còn lỗi Target Device Version không

## ⚠️ **Lưu ý quan trọng:**

- **Codemagic UI** override YAML settings
- **Xcode 16.4** gây lỗi Target Device Version
- **Xcode 14.3** ổn định và được test
- **Manual change** trong dashboard là bắt buộc

## 🔍 **Debug Steps:**

1. **Kiểm tra Xcode version** trong Codemagic dashboard
2. **Thay đổi thành 14.3** nếu đang là Latest (16.4)
3. **Test build** với framework-only trước
4. **Test full iOS build** nếu cần TestFlight

## 📱 **Workflows có sẵn:**

- **codemagic.yaml**: Framework build (đơn giản nhất)
- **codemagic_full_ios_xcode14.yaml**: Full iOS + TestFlight
- **codemagic_debug_xcode14.yaml**: Debug build

## 🎯 **Expected Result:**

Sau khi thay đổi Xcode version trong dashboard:
- ✅ Build thành công
- ✅ Không còn lỗi Target Device Version
- ✅ Framework được tạo
- ✅ Có thể deploy lên TestFlight
"""
    
    with open('MANUAL_FIX_GUIDE.md', 'w') as f:
        f.write(guide_content)
    
    print("✅ MANUAL_FIX_GUIDE.md đã được tạo")

def main():
    """Main function"""
    print("🚨 FINAL FIX FOR TARGET DEVICE VERSION ERROR")
    print("=" * 60)
    
    print("\n📋 Vấn đề:")
    print("1. Lỗi: 'Failed to parse Target Device Version'")
    print("2. Nguyên nhân: Xcode 16.4 trong Codemagic dashboard")
    print("3. Giải pháp: Manual change trong dashboard")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix project.pbxproj
    fix_project_pbxproj()
    
    # Create simple codemagic
    create_simple_codemagic()
    
    # Create manual guide
    create_manual_guide()
    
    print("\n" + "=" * 60)
    print("✅ FINAL FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n🚨 BƯỚC QUAN TRỌNG:")
    print("1. Vào Codemagic Dashboard")
    print("2. Workflow Editor")
    print("3. Environment section")
    print("4. Thay đổi Xcode version từ 'Latest (16.4)' thành '14.3'")
    print("5. Save và test build")
    
    print("\n📋 Alternative:")
    print("- Switch to YAML configuration")
    print("- Copy nội dung từ codemagic.yaml")
    print("- Save và test")

if __name__ == "__main__":
    main() 