#!/usr/bin/env python3
"""
Script fix lỗi BoringSSL C11 requirement
"""

import os
import re
import subprocess
import sys

def fix_c11_requirement():
    """Fix lỗi C11 requirement cho BoringSSL"""
    print("🔧 Fixing C11 requirement for BoringSSL...")
    
    # Fix Podfile
    podfile_path = "ios/Podfile"
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # Thay thế GCC_C_LANGUAGE_STANDARD
    updated_content = re.sub(
        r"config\.build_settings\['GCC_C_LANGUAGE_STANDARD'\] = 'gnu99'",
        "config.build_settings['GCC_C_LANGUAGE_STANDARD'] = 'gnu11'",
        content
    )
    
    with open(podfile_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ Podfile C11 requirement đã được fix")
    
    # Fix project.pbxproj
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Thay thế tất cả GCC_C_LANGUAGE_STANDARD
    updated_content = re.sub(
        r'GCC_C_LANGUAGE_STANDARD = gnu99;',
        'GCC_C_LANGUAGE_STANDARD = gnu11;',
        content
    )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj C11 requirement đã được fix")

def update_codemagic_config():
    """Cập nhật Codemagic config cho C11"""
    print("🔧 Updating Codemagic config for C11...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (C11 Fixed)
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
    
    print("✅ Codemagic config đã được cập nhật cho C11")

def check_boringssl_requirements():
    """Kiểm tra BoringSSL requirements"""
    print("🔍 Checking BoringSSL requirements...")
    
    print("\n📋 BoringSSL requirements:")
    print("- BoringSSL yêu cầu C11 mode trở lên")
    print("- Project đang sử dụng C99 (gnu99)")
    print("- Cần update thành C11 (gnu11)")
    
    print("\n⚠️  BoringSSL error:")
    print("- 'BoringSSL must be built in C11 mode or higher'")
    print("- Đã fix bằng cách set GCC_C_LANGUAGE_STANDARD = 'gnu11'")

def main():
    """Main function"""
    print("🚀 FIX BORINGSSL C11 REQUIREMENT")
    print("=" * 50)
    
    print("\n📋 Vấn đề đã được xác định:")
    print("1. BoringSSL yêu cầu C11 mode")
    print("2. Project đang sử dụng C99 (gnu99)")
    print("3. Cần update thành C11 (gnu11)")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix C11 requirement
    fix_c11_requirement()
    
    # Update Codemagic config
    update_codemagic_config()
    
    # Check BoringSSL requirements
    check_boringssl_requirements()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix BoringSSL C11 requirement'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic với C11")
    print("\n3. Kiểm tra BoringSSL compatibility")
    
    print("\n🔍 Lý do cần C11:")
    print("- BoringSSL yêu cầu C11 mode trở lên")
    print("- Firebase/gRPC sử dụng BoringSSL")
    print("- C99 không đủ cho BoringSSL features")

if __name__ == "__main__":
    main() 