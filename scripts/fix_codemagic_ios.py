#!/usr/bin/env python3
"""
Script fix lỗi Codemagic iOS build
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

def update_codemagic_config():
    """Cập nhật cấu hình Codemagic"""
    print("🔧 Updating Codemagic config...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (Fixed)
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

def update_podfile():
    """Cập nhật Podfile để tránh lỗi compiler"""
    print("🔧 Updating Podfile...")
    
    podfile_content = """# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Ultra minimal iOS build settings to avoid compiler conflicts
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      
      # Remove ALL potentially problematic compiler flags
      config.build_settings.delete('GCC_OPTIMIZATION_LEVEL')
      config.build_settings.delete('GCC_PREPROCESSOR_DEFINITIONS')
      config.build_settings.delete('CLANG_WARN_STRICT_PROTOTYPES')
      config.build_settings.delete('CLANG_WARN_UNREACHABLE_CODE')
      config.build_settings.delete('CLANG_WARN_EMPTY_BODY')
      config.build_settings.delete('GCC_WARN_64_TO_32_BIT_CONVERSION')
      config.build_settings.delete('GCC_WARN_ABOUT_RETURN_TYPE')
      config.build_settings.delete('GCC_WARN_UNDECLARED_SELECTOR')
      config.build_settings.delete('GCC_WARN_UNINITIALIZED_AUTOS')
      config.build_settings.delete('GCC_WARN_UNUSED_FUNCTION')
      config.build_settings.delete('GCC_WARN_UNUSED_VARIABLE')
      config.build_settings.delete('CLANG_WARN_BOOL_CONVERSION')
      config.build_settings.delete('CLANG_WARN_CONSTANT_CONVERSION')
      config.build_settings.delete('CLANG_WARN_ENUM_CONVERSION')
      config.build_settings.delete('CLANG_WARN_INT_CONVERSION')
      config.build_settings.delete('CLANG_WARN_NON_LITERAL_NULL_CONVERSION')
      config.build_settings.delete('CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF')
      config.build_settings.delete('CLANG_WARN_OBJC_LITERAL_CONVERSION')
      config.build_settings.delete('CLANG_WARN_RANGE_LOOP_ANALYSIS')
      config.build_settings.delete('CLANG_WARN_SUSPICIOUS_MOVE')
      config.build_settings.delete('CLANG_WARN__DUPLICATE_METHOD_MATCH')
      
      # Set safe defaults
      config.build_settings['GCC_C_LANGUAGE_STANDARD'] = 'gnu99'
      config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++0x'
      config.build_settings['CLANG_CXX_LIBRARY'] = 'libc++'
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
      
      # Additional fixes for Codemagic
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    end
  end
end
"""
    
    with open('ios/Podfile', 'w') as f:
        f.write(podfile_content)
    
    print("✅ Podfile đã được cập nhật")

def create_alternative_workflow():
    """Tạo workflow thay thế cho Codemagic"""
    print("🔧 Creating alternative workflow...")
    
    alt_workflow = """workflows:
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
        f.write(alt_workflow)
    
    print("✅ Alternative workflow đã được tạo: codemagic_simple.yaml")

def main():
    """Main function"""
    print("🚀 FIX CODEMAGIC IOS BUILD ISSUES")
    print("=" * 50)
    
    print("\n📋 Các vấn đề đã được xác định:")
    print("1. Bundle ID không khớp")
    print("2. Compiler flags conflict")
    print("3. Build process khác với GitHub Actions")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Fix Bundle ID
    fix_bundle_id()
    
    # Update Codemagic config
    update_codemagic_config()
    
    # Update Podfile
    update_podfile()
    
    # Create alternative workflow
    create_alternative_workflow()
    
    print("\n" + "=" * 50)
    print("✅ TẤT CẢ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix Codemagic iOS build issues'")
    print("   git push origin main")
    print("\n2. Test trên Codemagic với workflow mới")
    print("\n3. Nếu vẫn lỗi, sử dụng codemagic_simple.yaml")
    
    print("\n🔍 Lý do GitHub Actions OK mà Codemagic lỗi:")
    print("- GitHub Actions: build iOS Framework (không full app)")
    print("- Codemagic: build full iOS app với code signing")
    print("- Compiler flags conflict khi build full app")

if __name__ == "__main__":
    main() 