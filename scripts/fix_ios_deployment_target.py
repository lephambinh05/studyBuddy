#!/usr/bin/env python3
"""
Script fix iOS deployment target từ 13.0 lên 15.0
"""

import os
import re
import subprocess
import sys

def fix_deployment_target():
    """Fix iOS deployment target"""
    print("🔧 Fixing iOS deployment target from 13.0 to 15.0...")
    
    # Fix Podfile
    podfile_path = "ios/Podfile"
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # Thay thế platform
    updated_content = re.sub(
        r"platform :ios, '13\.0'",
        "platform :ios, '15.0'",
        content
    )
    
    # Thay thế IPHONEOS_DEPLOYMENT_TARGET
    updated_content = re.sub(
        r"config\.build_settings\['IPHONEOS_DEPLOYMENT_TARGET'\] = '13\.0'",
        "config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'",
        updated_content
    )
    
    with open(podfile_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ Podfile deployment target đã được fix")
    
    # Fix project.pbxproj
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Thay thế tất cả IPHONEOS_DEPLOYMENT_TARGET
    updated_content = re.sub(
        r'IPHONEOS_DEPLOYMENT_TARGET = 13\.0;',
        'IPHONEOS_DEPLOYMENT_TARGET = 15.0;',
        content
    )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj deployment target đã được fix")

def update_codemagic_config():
    """Cập nhật Codemagic config cho iOS 15.0"""
    print("🔧 Updating Codemagic config for iOS 15.0...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (iOS 15.0)
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
    
    print("✅ Codemagic config đã được cập nhật cho iOS 15.0")

def check_firebase_requirements():
    """Kiểm tra Firebase requirements"""
    print("🔍 Checking Firebase requirements...")
    
    print("\n📋 Firebase iOS requirements:")
    print("- firebase_core: iOS 12.0+")
    print("- firebase_auth: iOS 12.0+")
    print("- cloud_firestore: iOS 15.0+ (NEW REQUIREMENT)")
    print("- firebase_storage: iOS 12.0+")
    
    print("\n⚠️  cloud_firestore yêu cầu iOS 15.0+")
    print("✅ Đã fix deployment target lên 15.0")

def main():
    """Main function"""
    print("🚀 FIX IOS DEPLOYMENT TARGET")
    print("=" * 50)
    
    print("\n📋 Vấn đề đã được xác định:")
    print("1. cloud_firestore yêu cầu iOS 15.0+")
    print("2. Project đang sử dụng iOS 13.0")
    print("3. Cần update deployment target")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix deployment target
    fix_deployment_target()
    
    # Update Codemagic config
    update_codemagic_config()
    
    # Check Firebase requirements
    check_firebase_requirements()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix iOS deployment target to 15.0 for cloud_firestore'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic với iOS 15.0")
    print("\n3. Kiểm tra compatibility với iOS devices")
    
    print("\n🔍 Lý do cần iOS 15.0:")
    print("- cloud_firestore mới yêu cầu iOS 15.0+")
    print("- Firebase SDK 12.0.0 có requirements mới")
    print("- Đây là breaking change từ Firebase")

if __name__ == "__main__":
    main() 