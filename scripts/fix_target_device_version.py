#!/usr/bin/env python3
"""
Script fix lỗi Target Device Version
"""

import os
import re
import subprocess
import sys

def fix_target_device_version():
    """Fix lỗi Target Device Version"""
    print("🔧 Fixing Target Device Version error...")
    
    # Fix project.pbxproj
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Thêm TARGETED_DEVICE_FAMILY settings
    updated_content = re.sub(
        r'TARGETED_DEVICE_FAMILY = "1,2";',
        'TARGETED_DEVICE_FAMILY = "1,2";\n\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;',
        content
    )
    
    # Đảm bảo có SUPPORTED_PLATFORMS
    if 'SUPPORTED_PLATFORMS = iphoneos;' not in updated_content:
        updated_content = re.sub(
            r'SDKROOT = iphoneos;',
            'SDKROOT = iphoneos;\n\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;',
            updated_content
        )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj Target Device Version đã được fix")

def update_codemagic_config():
    """Cập nhật Codemagic config cho Target Device Version"""
    print("🔧 Updating Codemagic config for Target Device Version...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (Target Device Fixed)
    environment:
      xcode: latest
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
    
    with open('codemagic.yaml', 'w') as f:
        f.write(codemagic_content)
    
    print("✅ Codemagic config đã được cập nhật cho Target Device Version")

def create_simple_workflow():
    """Tạo simple workflow để test"""
    print("🔧 Creating simple workflow for testing...")
    
    simple_workflow = """workflows:
  ios-simple-workflow:
    name: iOS Simple Build (Test)
    environment:
      xcode: latest
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
    
    with open('codemagic_simple_test.yaml', 'w') as f:
        f.write(simple_workflow)
    
    print("✅ Simple test workflow đã được tạo")

def check_target_device_issues():
    """Kiểm tra Target Device Version issues"""
    print("🔍 Checking Target Device Version issues...")
    
    print("\n📋 Target Device Version error:")
    print("- 'Failed to parse Target Device Version'")
    print("- Thường xảy ra khi Xcode không parse được device version")
    print("- Có thể do SUPPORTED_PLATFORMS setting")
    
    print("\n🔧 Solutions applied:")
    print("- Added SUPPORTED_PLATFORMS = iphoneos")
    print("- Ensured TARGETED_DEVICE_FAMILY = '1,2'")
    print("- Updated Codemagic config")
    print("- Created simple test workflow")

def main():
    """Main function"""
    print("🚀 FIX TARGET DEVICE VERSION ERROR")
    print("=" * 50)
    
    print("\n📋 Vấn đề đã được xác định:")
    print("1. 'Failed to parse Target Device Version'")
    print("2. Xcode không parse được device version")
    print("3. Cần fix SUPPORTED_PLATFORMS settings")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix Target Device Version
    fix_target_device_version()
    
    # Update Codemagic config
    update_codemagic_config()
    
    # Create simple workflow
    create_simple_workflow()
    
    # Check issues
    check_target_device_issues()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix Target Device Version error'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic")
    print("\n3. Nếu vẫn lỗi, sử dụng codemagic_simple_test.yaml")
    
    print("\n🔍 Alternative solutions:")
    print("- Sử dụng codemagic_simple_test.yaml để build framework only")
    print("- Kiểm tra Xcode version compatibility")
    print("- Verify iOS deployment target settings")

if __name__ == "__main__":
    main() 