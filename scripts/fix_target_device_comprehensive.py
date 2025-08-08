#!/usr/bin/env python3
"""
Script comprehensive fix lỗi Target Device Version
"""

import os
import re
import subprocess
import sys

def fix_target_device_comprehensive():
    """Fix lỗi Target Device Version một cách toàn diện"""
    print("🔧 Comprehensive fix for Target Device Version error...")
    
    # Fix project.pbxproj
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Thêm tất cả settings cần thiết
    updated_content = re.sub(
        r'TARGETED_DEVICE_FAMILY = "1,2";',
        'TARGETED_DEVICE_FAMILY = "1,2";\n\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;\n\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;\n\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;',
        content
    )
    
    # Đảm bảo có SDKROOT
    if 'SDKROOT = iphoneos;' not in updated_content:
        updated_content = re.sub(
            r'IPHONEOS_DEPLOYMENT_TARGET = 15\.0;',
            'IPHONEOS_DEPLOYMENT_TARGET = 15.0;\n\t\t\t\tSDKROOT = iphoneos;',
            updated_content
        )
    
    # Thêm VALIDATE_PRODUCT
    if 'VALIDATE_PRODUCT = YES;' not in updated_content:
        updated_content = re.sub(
            r'SWIFT_OPTIMIZATION_LEVEL = "-O";',
            'SWIFT_OPTIMIZATION_LEVEL = "-O";\n\t\t\t\tVALIDATE_PRODUCT = YES;',
            updated_content
        )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj comprehensive fix đã được áp dụng")

def update_codemagic_xcode_version():
    """Cập nhật Codemagic với Xcode version cụ thể"""
    print("🔧 Updating Codemagic with specific Xcode version...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Framework Build (Xcode 15.0)
    environment:
      xcode: 15.0
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
    
    print("✅ Codemagic config đã được cập nhật với Xcode 15.0")

def create_debug_workflow():
    """Tạo debug workflow để test"""
    print("🔧 Creating debug workflow...")
    
    debug_workflow = """workflows:
  ios-debug-workflow:
    name: iOS Debug Build (Xcode 15.0)
    environment:
      xcode: 15.0
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
    
    with open('codemagic_debug_xcode15.yaml', 'w') as f:
        f.write(debug_workflow)
    
    print("✅ Debug workflow với Xcode 15.0 đã được tạo")

def check_target_device_issues():
    """Kiểm tra Target Device Version issues"""
    print("🔍 Checking Target Device Version issues...")
    
    print("\n📋 Target Device Version error analysis:")
    print("- 'Failed to parse Target Device Version'")
    print("- Thường xảy ra với Xcode version không tương thích")
    print("- Cần dùng Xcode version cụ thể thay vì 'latest'")
    
    print("\n🔧 Solutions applied:")
    print("- Changed Xcode from 'latest' to '15.0'")
    print("- Added comprehensive SUPPORTED_PLATFORMS settings")
    print("- Added VALIDATE_PRODUCT = YES")
    print("- Created debug workflow với Xcode 15.0")

def main():
    """Main function"""
    print("🚀 COMPREHENSIVE FIX TARGET DEVICE VERSION ERROR")
    print("=" * 60)
    
    print("\n📋 Vấn đề đã được xác định:")
    print("1. 'Failed to parse Target Device Version'")
    print("2. Xcode version không tương thích")
    print("3. Build settings thiếu hoặc conflict")
    
    print("\n🔧 Thực hiện comprehensive fixes...")
    
    # Fix Target Device Version comprehensive
    fix_target_device_comprehensive()
    
    # Update Codemagic với Xcode version cụ thể
    update_codemagic_xcode_version()
    
    # Create debug workflow
    create_debug_workflow()
    
    # Check issues
    check_target_device_issues()
    
    print("\n" + "=" * 60)
    print("✅ TẤT CẢ COMPREHENSIVE FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Comprehensive fix Target Device Version with Xcode 15.0'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic với Xcode 15.0")
    print("\n3. Nếu vẫn lỗi, sử dụng codemagic_debug_xcode15.yaml")
    
    print("\n🔍 Alternative solutions:")
    print("- Sử dụng Xcode 15.0 thay vì 'latest'")
    print("- Test với debug workflow trước")
    print("- Manual build nếu cần TestFlight")

if __name__ == "__main__":
    main() 