#!/usr/bin/env python3
"""
Script kiểm tra cấu hình iOS cho TestFlight deployment
"""

import os
import re
import subprocess
import sys
from pathlib import Path

def check_bundle_id():
    """Kiểm tra Bundle ID trong project"""
    print("🔍 Kiểm tra Bundle ID...")
    
    # Kiểm tra trong project.pbxproj
    pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
    if not os.path.exists(pbxproj_path):
        print("❌ Không tìm thấy file project.pbxproj")
        return False
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Tìm PRODUCT_BUNDLE_IDENTIFIER
    bundle_id_match = re.search(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);', content)
    if bundle_id_match:
        bundle_id = bundle_id_match.group(1).strip()
        print(f"📱 Bundle ID hiện tại: {bundle_id}")
        
        if bundle_id == "com.example.studybuddy":
            print("⚠️  Bundle ID là example, cần thay đổi thành com.studybuddy.app")
            return False
        elif bundle_id == "com.studybuddy.app":
            print("✅ Bundle ID đã đúng: com.studybuddy.app")
            return True
        else:
            print(f"⚠️  Bundle ID không khớp: {bundle_id}")
            return False
    else:
        print("❌ Không tìm thấy PRODUCT_BUNDLE_IDENTIFIER")
        return False

def check_codemagic_config():
    """Kiểm tra cấu hình Codemagic"""
    print("\n🔍 Kiểm tra cấu hình Codemagic...")
    
    if not os.path.exists("codemagic.yaml"):
        print("❌ Không tìm thấy file codemagic.yaml")
        return False
    
    with open("codemagic.yaml", 'r') as f:
        content = f.read()
    
    # Kiểm tra Bundle ID trong codemagic.yaml
    if "com.studybuddy.app" in content:
        print("✅ Bundle ID trong codemagic.yaml đã đúng")
        return True
    else:
        print("❌ Bundle ID trong codemagic.yaml không khớp")
        return False

def check_export_options():
    """Kiểm tra ExportOptions.plist"""
    print("\n🔍 Kiểm tra ExportOptions.plist...")
    
    export_options_path = "ios/ExportOptions.plist"
    if not os.path.exists(export_options_path):
        print("❌ Không tìm thấy ExportOptions.plist")
        return False
    
    with open(export_options_path, 'r') as f:
        content = f.read()
    
    if "YOUR_TEAM_ID" in content:
        print("⚠️  Cần cập nhật TEAM_ID trong ExportOptions.plist")
        return False
    else:
        print("✅ ExportOptions.plist đã được cấu hình")
        return True

def check_firebase_config():
    """Kiểm tra cấu hình Firebase cho iOS"""
    print("\n🔍 Kiểm tra cấu hình Firebase...")
    
    google_service_path = "ios/Runner/GoogleService-Info.plist"
    if os.path.exists(google_service_path):
        print("✅ GoogleService-Info.plist đã tồn tại")
        return True
    else:
        print("❌ Không tìm thấy GoogleService-Info.plist")
        print("📥 Tải từ Firebase Console: https://console.firebase.google.com")
        return False

def check_podfile():
    """Kiểm tra Podfile"""
    print("\n🔍 Kiểm tra Podfile...")
    
    podfile_path = "ios/Podfile"
    if not os.path.exists(podfile_path):
        print("❌ Không tìm thấy Podfile")
        return False
    
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    if "platform :ios, '13.0'" in content:
        print("✅ iOS deployment target đã đúng (13.0)")
        return True
    else:
        print("⚠️  iOS deployment target có thể cần cập nhật")
        return False

def update_bundle_id():
    """Cập nhật Bundle ID thành com.studybuddy.app"""
    print("\n🔧 Cập nhật Bundle ID...")
    
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
    
    print("✅ Đã cập nhật Bundle ID thành com.studybuddy.app")

def main():
    """Main function"""
    print("🚀 KIỂM TRA CẤU HÌNH IOS CHO TESTFLIGHT")
    print("=" * 50)
    
    checks = [
        ("Bundle ID", check_bundle_id),
        ("Codemagic Config", check_codemagic_config),
        ("Export Options", check_export_options),
        ("Firebase Config", check_firebase_config),
        ("Podfile", check_podfile),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ Lỗi kiểm tra {name}: {e}")
            results.append((name, False))
    
    print("\n" + "=" * 50)
    print("📊 KẾT QUẢ KIỂM TRA:")
    
    all_passed = True
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{name}: {status}")
        if not result:
            all_passed = False
    
    print("\n" + "=" * 50)
    
    if all_passed:
        print("🎉 Tất cả kiểm tra đã PASS! Sẵn sàng deploy TestFlight")
        print("\n📋 Bước tiếp theo:")
        print("1. Tạo app trên App Store Connect")
        print("2. Tạo API Key cho Codemagic")
        print("3. Setup environment variables")
        print("4. Push code để trigger build")
    else:
        print("⚠️  Có một số vấn đề cần sửa:")
        
        # Kiểm tra Bundle ID
        if not check_bundle_id():
            print("\n🔧 Sửa Bundle ID? (y/n): ", end="")
            if input().lower() == 'y':
                update_bundle_id()
        
        print("\n📋 Cần thực hiện:")
        print("1. Sửa các vấn đề trên")
        print("2. Tạo app trên App Store Connect")
        print("3. Tạo API Key cho Codemagic")
        print("4. Setup environment variables")

if __name__ == "__main__":
    main() 