#!/usr/bin/env python3
"""
Script kiểm tra và khắc phục vấn đề Firebase trong APK
"""

import json
import os
import subprocess
import sys
from pathlib import Path

def check_file_exists(file_path):
    """Kiểm tra file có tồn tại không"""
    return Path(file_path).exists()

def read_json_file(file_path):
    """Đọc file JSON"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Lỗi đọc file {file_path}: {e}")
        return None

def check_google_services_json():
    """Kiểm tra file google-services.json"""
    print("🔍 Kiểm tra google-services.json...")
    
    file_path = "android/app/google-services.json"
    if not check_file_exists(file_path):
        print("❌ Không tìm thấy google-services.json")
        return False
    
    data = read_json_file(file_path)
    if not data:
        return False
    
    # Kiểm tra cấu trúc cơ bản
    if 'client' not in data or 'project_info' not in data:
        print("❌ google-services.json không đúng định dạng")
        return False
    
    # Kiểm tra package name
    package_name = None
    for client in data['client']:
        if 'client_info' in client and 'android_client_info' in client['client_info']:
            package_name = client['client_info']['android_client_info'].get('package_name')
            break
    
    if not package_name:
        print("❌ Không tìm thấy package_name trong google-services.json")
        return False
    
    print(f"✅ Package name: {package_name}")
    print(f"✅ Project ID: {data['project_info'].get('project_id', 'N/A')}")
    return True

def check_build_gradle():
    """Kiểm tra build.gradle.kts"""
    print("\n🔍 Kiểm tra build.gradle.kts...")
    
    file_path = "android/app/build.gradle.kts"
    if not check_file_exists(file_path):
        print("❌ Không tìm thấy build.gradle.kts")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Kiểm tra Google Services plugin
    if 'id("com.google.gms.google-services")' not in content:
        print("❌ Thiếu Google Services plugin trong build.gradle.kts")
        return False
    
    # Kiểm tra applicationId
    if 'applicationId = "com.studybuddy.app"' not in content:
        print("❌ applicationId không khớp với package name")
        return False
    
    print("✅ Google Services plugin đã được cấu hình")
    print("✅ ApplicationId khớp với package name")
    return True

def check_firebase_options():
    """Kiểm tra firebase_options.dart"""
    print("\n🔍 Kiểm tra firebase_options.dart...")
    
    file_path = "lib/firebase_options.dart"
    if not check_file_exists(file_path):
        print("❌ Không tìm thấy firebase_options.dart")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Kiểm tra Android configuration
    if 'TargetPlatform.android:' not in content:
        print("❌ Thiếu cấu hình Android trong firebase_options.dart")
        return False
    
    print("✅ firebase_options.dart đã được cấu hình cho Android")
    return True

def get_sha1_fingerprint():
    """Lấy SHA-1 fingerprint"""
    print("\n🔍 Lấy SHA-1 fingerprint...")
    
    try:
        # Thử lấy debug keystore SHA-1
        result = subprocess.run([
            'keytool', '-list', '-v', '-keystore', 
            os.path.expanduser('~/.android/debug.keystore'),
            '-alias', 'androiddebugkey', '-storepass', 'android', '-keypass', 'android'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if 'SHA1:' in line:
                    sha1 = line.split('SHA1:')[1].strip()
                    print(f"✅ Debug SHA-1: {sha1}")
                    return sha1
        
        print("❌ Không thể lấy SHA-1 fingerprint")
        return None
        
    except Exception as e:
        print(f"❌ Lỗi khi lấy SHA-1: {e}")
        return None

def check_firebase_console_setup():
    """Hướng dẫn cài đặt Firebase Console"""
    print("\n📋 HƯỚNG DẪN CÀI ĐẶT FIREBASE CONSOLE:")
    print("1. Truy cập https://console.firebase.google.com")
    print("2. Chọn project: studybuddy-8bfaa")
    print("3. Vào Project Settings > General")
    print("4. Trong phần 'Your apps', chọn Android app")
    print("5. Thêm SHA-1 fingerprint vào app")
    print("6. Tải xuống google-services.json mới")
    print("7. Thay thế file cũ trong android/app/")

def main():
    """Hàm chính"""
    print("🚀 KIỂM TRA CẤU HÌNH FIREBASE CHO APK")
    print("=" * 50)
    
    checks = [
        check_google_services_json(),
        check_build_gradle(),
        check_firebase_options()
    ]
    
    sha1 = get_sha1_fingerprint()
    
    print("\n" + "=" * 50)
    print("📊 KẾT QUẢ KIỂM TRA:")
    
    if all(checks):
        print("✅ Tất cả cấu hình cơ bản đều đúng")
    else:
        print("❌ Có vấn đề với cấu hình Firebase")
    
    if sha1:
        print(f"✅ SHA-1 fingerprint: {sha1}")
        print("⚠️  Hãy đảm bảo SHA-1 này đã được thêm vào Firebase Console")
    else:
        print("❌ Không thể lấy SHA-1 fingerprint")
    
    print("\n🔧 CÁC BƯỚC KHẮC PHỤC:")
    print("1. Chạy: flutter clean")
    print("2. Chạy: flutter pub get")
    print("3. Đảm bảo SHA-1 đã được thêm vào Firebase Console")
    print("4. Build APK: flutter build apk --release")
    print("5. Test APK trên thiết bị thật")
    
    if not all(checks):
        check_firebase_console_setup()

if __name__ == "__main__":
    main() 