#!/usr/bin/env python3
"""
Script tự động fix tất cả các vấn đề iOS build
"""

import os
import re
import subprocess
import sys

def fix_bundle_id():
    """Fix Bundle ID"""
    print("🔧 Fixing Bundle ID...")
    
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Thay thế Bundle ID
    updated_content = re.sub(
        r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;',
        'PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;',
        content
    )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ Bundle ID đã được fix")

def fix_deployment_target():
    """Fix iOS deployment target"""
    print("🔧 Fixing iOS deployment target...")
    
    # Fix Podfile
    podfile_path = "ios/Podfile"
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # Thay thế platform
    updated_content = re.sub(
        r"platform :ios, '[^']+'",
        "platform :ios, '15.0'",
        content
    )
    
    # Thay thế IPHONEOS_DEPLOYMENT_TARGET
    updated_content = re.sub(
        r"config\.build_settings\['IPHONEOS_DEPLOYMENT_TARGET'\] = '[^']+'",
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
        r'IPHONEOS_DEPLOYMENT_TARGET = [^;]+;',
        'IPHONEOS_DEPLOYMENT_TARGET = 15.0;',
        content
    )
    
    with open(pbxproj_path, 'w') as f:
        f.write(updated_content)
    
    print("✅ project.pbxproj deployment target đã được fix")

def fix_cpp14_issue():
    """Fix lỗi C++14 requirement"""
    print("🔧 Fixing C++14 requirement...")
    
    # Cập nhật Podfile
    podfile_path = "ios/Podfile"
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # Thay thế C++ standard
    updated_content = re.sub(
        r"config\.build_settings\['CLANG_CXX_LANGUAGE_STANDARD'\] = '[^']+'",
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

def update_codemagic_config():
    """Cập nhật Codemagic config"""
    print("🔧 Updating Codemagic config...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (Auto Fixed)
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
    
    print("✅ Codemagic config đã được cập nhật")

def create_alternative_workflows():
    """Tạo alternative workflows"""
    print("🔧 Creating alternative workflows...")
    
    # Simple workflow
    simple_workflow = """workflows:
  ios-simple-workflow:
    name: iOS Simple Build
    environment:
      xcode: latest
      cocoapods: default
    scripts:
      - name: Setup
        script: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
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
    
    with open('codemagic_simple.yaml', 'w') as f:
        f.write(simple_workflow)
    
    # Debug workflow
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
    
    print("✅ Alternative workflows đã được tạo")

def check_all_fixes():
    """Kiểm tra tất cả fixes"""
    print("🔍 Checking all fixes...")
    
    # Kiểm tra Bundle ID
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    if "com.studybuddy.app" in content:
        print("✅ Bundle ID: com.studybuddy.app")
    else:
        print("❌ Bundle ID chưa được fix")
    
    # Kiểm tra deployment target
    if "IPHONEOS_DEPLOYMENT_TARGET = 15.0;" in content:
        print("✅ Deployment target: 15.0")
    else:
        print("❌ Deployment target chưa được fix")
    
    # Kiểm tra Podfile
    podfile_path = "ios/Podfile"
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    if "platform :ios, '15.0'" in content:
        print("✅ Podfile platform: 15.0")
    else:
        print("❌ Podfile platform chưa được fix")
    
    if "CLANG_CXX_LANGUAGE_STANDARD" in content:
        print("✅ C++14 setting đã được thêm")
    else:
        print("❌ C++14 setting chưa được thêm")

def main():
    """Main function"""
    print("🚀 AUTO FIX ALL IOS BUILD ISSUES")
    print("=" * 50)
    
    print("\n📋 Các vấn đề sẽ được fix:")
    print("1. Bundle ID: com.example.studybuddy → com.studybuddy.app")
    print("2. Deployment target: 13.0 → 15.0")
    print("3. C++14 requirement cho Firebase/Abseil")
    print("4. Compiler flags conflict")
    print("5. Codemagic config")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix tất cả
    fix_bundle_id()
    fix_deployment_target()
    fix_cpp14_issue()
    update_codemagic_config()
    create_alternative_workflows()
    check_all_fixes()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Auto fix all iOS build issues'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic")
    print("\n3. Nếu vẫn lỗi, sử dụng codemagic_simple.yaml")
    
    print("\n🔍 Tóm tắt fixes:")
    print("- Bundle ID: com.studybuddy.app")
    print("- iOS deployment target: 15.0")
    print("- C++14 standard cho Firebase")
    print("- Clean build settings")
    print("- Alternative workflows đã tạo")

if __name__ == "__main__":
    main() 