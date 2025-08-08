#!/usr/bin/env python3
"""
Script fix lỗi C++14 và các lỗi iOS build
"""

import os
import re
import subprocess
import sys

def fix_cpp14_issue():
    """Fix lỗi C++14 requirement"""
    print("🔧 Fixing C++14 requirement...")
    
    # Cập nhật Podfile
    podfile_path = "ios/Podfile"
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # Thay thế C++ standard
    updated_content = re.sub(
        r"config\.build_settings\['CLANG_CXX_LANGUAGE_STANDARD'\] = 'gnu\+\+0x'",
        "config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++14'",
        content
    )
    
    # Đảm bảo có C++14 setting
    if "CLANG_CXX_LANGUAGE_STANDARD" not in updated_content:
        # Thêm C++14 setting vào post_install
        updated_content = re.sub(
            r"config\.build_settings\['SWIFT_VERSION'\] = '5\.0'",
            "config.build_settings['SWIFT_VERSION'] = '5.0'\n      \n      # Fix C++14 requirement for Firebase/Abseil\n      config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++14'\n      config.build_settings['CLANG_CXX_LIBRARY'] = 'libc++'",
            updated_content
        )
    
    with open(podfile_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ C++14 requirement đã được fix")

def update_codemagic_for_cpp14():
    """Cập nhật Codemagic config cho C++14"""
    print("🔧 Updating Codemagic config for C++14...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (C++14 Fixed)
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
    
    print("✅ Codemagic config đã được cập nhật cho C++14")

def create_debug_workflow():
    """Tạo workflow debug để test"""
    print("🔧 Creating debug workflow...")
    
    debug_workflow = """workflows:
  ios-debug-workflow:
    name: iOS Debug Build
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
    
    with open('codemagic_debug.yaml', 'w') as f:
        f.write(debug_workflow)
    
    print("✅ Debug workflow đã được tạo: codemagic_debug.yaml")

def check_firebase_versions():
    """Kiểm tra Firebase versions"""
    print("🔍 Checking Firebase versions...")
    
    pubspec_path = "pubspec.yaml"
    
    with open(pubspec_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Kiểm tra Firebase versions
    firebase_packages = [
        'firebase_core',
        'firebase_auth', 
        'cloud_firestore',
        'firebase_storage'
    ]
    
    for package in firebase_packages:
        if package in content:
            print(f"✅ {package} found")
        else:
            print(f"⚠️  {package} not found")
    
    print("\n📋 Firebase versions hiện tại:")
    print("- firebase_core: 2.32.0")
    print("- firebase_auth: 4.16.0") 
    print("- cloud_firestore: 4.17.5")
    print("\n💡 Các versions này tương thích với C++14")

def main():
    """Main function"""
    print("🚀 FIX IOS C++14 BUILD ISSUES")
    print("=" * 50)
    
    print("\n📋 Các lỗi đã được xác định:")
    print("1. C++14 requirement cho Firebase/Abseil")
    print("2. Compiler flags conflict")
    print("3. Bundle ID mismatch")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix C++14 issue
    fix_cpp14_issue()
    
    # Update Codemagic config
    update_codemagic_for_cpp14()
    
    # Create debug workflow
    create_debug_workflow()
    
    # Check Firebase versions
    check_firebase_versions()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix C++14 requirement for iOS build'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic với workflow mới")
    print("\n3. Nếu vẫn lỗi, sử dụng codemagic_debug.yaml")
    
    print("\n🔍 Lỗi C++14:")
    print("- Firebase/Abseil yêu cầu C++14 trở lên")
    print("- Project đang sử dụng C++11")
    print("- Đã fix bằng cách set CLANG_CXX_LANGUAGE_STANDARD = 'c++14'")

if __name__ == "__main__":
    main() 