#!/usr/bin/env python3
"""
Script build iOS trên Windows (sử dụng cloud services)
"""

import subprocess
import os
import json
import requests
from pathlib import Path

def check_windows_environment():
    """Kiểm tra môi trường Windows"""
    print("🔍 Kiểm tra môi trường Windows...")
    
    if os.name != 'nt':
        print("❌ Không phải Windows")
        return False
    
    # Kiểm tra Flutter
    try:
        result = subprocess.run(['flutter', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Flutter đã cài đặt")
        else:
            print("❌ Flutter chưa cài đặt")
            return False
    except FileNotFoundError:
        print("❌ Flutter chưa cài đặt")
        return False
    
    return True

def prepare_ios_build():
    """Chuẩn bị build iOS"""
    print("\n🔧 Chuẩn bị build iOS...")
    
    # Tạo iOS framework
    try:
        result = subprocess.run([
            'flutter', 'build', 'ios-framework',
            '--output=build/ios-framework'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ iOS framework đã tạo")
            return True
        else:
            print("❌ Lỗi tạo iOS framework")
            print(f"Lỗi: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return False

def create_codemagic_config():
    """Tạo file cấu hình Codemagic"""
    print("\n📝 Tạo cấu hình Codemagic...")
    
    codemagic_config = {
        "workflows": {
            "ios-workflow": {
                "name": "iOS Workflow",
                "environment": {
                    "xcode": "latest",
                    "cocoapods": "default",
                    "flutter": "stable"
                },
                "scripts": [
                    {
                        "name": "Build iOS",
                        "script": """
                        flutter pub get
                        flutter build ios --release
                        xcodebuild -workspace ios/Runner.xcworkspace \\
                          -scheme Runner \\
                          -configuration Release \\
                          -archivePath build/ios/Runner.xcarchive \\
                          archive
                        xcodebuild -exportArchive \\
                          -archivePath build/ios/Runner.xcarchive \\
                          -exportPath build/ios/ \\
                          -exportOptionsPlist ios/ExportOptions.plist
                        """
                    }
                ],
                "artifacts": [
                    "build/ios/Runner.ipa",
                    "build/ios/Runner.xcarchive"
                ]
            }
        }
    }
    
    try:
        with open('codemagic.yaml', 'w') as f:
            import yaml
            yaml.dump(codemagic_config, f, default_flow_style=False)
        print("✅ codemagic.yaml đã tạo")
        return True
    except Exception as e:
        print(f"❌ Lỗi tạo codemagic.yaml: {e}")
        return False

def create_github_actions():
    """Tạo GitHub Actions workflow"""
    print("\n📝 Tạo GitHub Actions workflow...")
    
    workflow_content = """name: iOS Build
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
          channel: 'stable'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build iOS
        run: |
          flutter build ios --release
          xcodebuild -workspace ios/Runner.xcworkspace \\
            -scheme Runner \\
            -configuration Release \\
            -archivePath build/ios/Runner.xcarchive \\
            archive
            
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \\
            -archivePath build/ios/Runner.xcarchive \\
            -exportPath build/ios/ \\
            -exportOptionsPlist ios/ExportOptions.plist
            
      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: ios-app
          path: build/ios/Runner.ipa
"""
    
    # Tạo thư mục .github/workflows
    workflows_dir = Path('.github/workflows')
    workflows_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        with open('.github/workflows/ios.yml', 'w') as f:
            f.write(workflow_content)
        print("✅ GitHub Actions workflow đã tạo")
        return True
    except Exception as e:
        print(f"❌ Lỗi tạo GitHub Actions: {e}")
        return False

def show_cloud_options():
    """Hiển thị các tùy chọn cloud"""
    print("\n☁️  CÁC TÙY CHỌN CLOUD BUILD:")
    print("=" * 50)
    
    print("\n1. 🚀 Codemagic CI/CD:")
    print("   - Tích hợp với GitHub/GitLab")
    print("   - Build tự động khi push code")
    print("   - Hỗ trợ cả Android và iOS")
    print("   - Giá: $0.02/phút build")
    print("   - Link: https://codemagic.io")
    
    print("\n2. 🐙 GitHub Actions:")
    print("   - Miễn phí cho public repos")
    print("   - 2000 phút/tháng cho private repos")
    print("   - Tích hợp với GitHub")
    print("   - Link: https://github.com/features/actions")
    
    print("\n3. 🔥 Firebase App Distribution:")
    print("   - Tích hợp với Firebase Console")
    print("   - Hỗ trợ cả Android và iOS")
    print("   - Miễn phí cho 100 testers")
    print("   - Link: https://firebase.google.com/docs/app-distribution")
    
    print("\n4. 💻 MacStadium:")
    print("   - Thuê Mac cloud")
    print("   - $0.50/giờ cho Mac mini")
    print("   - Full Xcode support")
    print("   - Link: https://www.macstadium.com")
    
    print("\n5. ☁️  MacinCloud:")
    print("   - Remote Mac access")
    print("   - Từ $1/giờ")
    print("   - Dedicated Mac servers")
    print("   - Link: https://www.macincloud.com")

def main():
    """Hàm chính"""
    print("🖥️  BUILD IOS TRÊN WINDOWS")
    print("=" * 50)
    
    # Kiểm tra môi trường
    if not check_windows_environment():
        print("\n❌ Môi trường Windows chưa sẵn sàng!")
        return
    
    print("\n✅ Môi trường Windows đã sẵn sàng!")
    
    # Chuẩn bị build
    if prepare_ios_build():
        print("\n✅ Đã chuẩn bị iOS framework!")
    
    # Tạo cấu hình cloud
    create_codemagic_config()
    create_github_actions()
    
    # Hiển thị tùy chọn
    show_cloud_options()
    
    print("\n📋 HƯỚNG DẪN TIẾP THEO:")
    print("1. Chọn một cloud service từ danh sách trên")
    print("2. Đăng ký và kết nối với repository")
    print("3. Push code lên GitHub/GitLab")
    print("4. Cloud service sẽ tự động build iOS")
    print("5. Tải IPA file từ cloud service")
    
    print("\n⚠️  LƯU Ý:")
    print("- Cần Apple Developer Account để upload TestFlight")
    print("- Cần cấu hình Firebase iOS trước")
    print("- Test kỹ trước khi release")

if __name__ == "__main__":
    main() 