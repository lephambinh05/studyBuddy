#!/usr/bin/env python3
"""
Script build iOS cho TestFlight
"""

import subprocess
import os
import json
from pathlib import Path

def check_ios_environment():
    """Kiểm tra môi trường iOS"""
    print("🔍 Kiểm tra môi trường iOS...")
    
    # Kiểm tra macOS
    if os.name != 'posix':
        print("❌ Cần macOS để build iOS")
        return False
    
    # Kiểm tra Xcode
    try:
        result = subprocess.run(['xcodebuild', '-version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Xcode đã cài đặt")
            print(result.stdout.strip())
        else:
            print("❌ Xcode chưa cài đặt")
            return False
    except FileNotFoundError:
        print("❌ Xcode chưa cài đặt")
        return False
    
    # Kiểm tra iOS devices
    try:
        result = subprocess.run(['xcrun', 'devicectl', 'list', 'devices'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ iOS devices:")
            print(result.stdout)
        else:
            print("⚠️  Không tìm thấy iOS devices")
    except FileNotFoundError:
        print("⚠️  Không thể kiểm tra iOS devices")
    
    return True

def check_firebase_ios_config():
    """Kiểm tra cấu hình Firebase cho iOS"""
    print("\n🔍 Kiểm tra cấu hình Firebase iOS...")
    
    # Kiểm tra GoogleService-Info.plist
    ios_config_path = "ios/Runner/GoogleService-Info.plist"
    if Path(ios_config_path).exists():
        print("✅ GoogleService-Info.plist đã tồn tại")
        return True
    else:
        print("❌ GoogleService-Info.plist chưa có")
        print("Hãy tải từ Firebase Console và đặt vào ios/Runner/")
        return False

def build_ios_app():
    """Build iOS app"""
    print("\n🚀 Build iOS app...")
    
    commands = [
        ("flutter clean", "Clean project"),
        ("flutter pub get", "Get dependencies"),
        ("flutter build ios --release", "Build iOS release"),
    ]
    
    for command, description in commands:
        print(f"\n🔧 {description}...")
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ {description} thành công!")
            else:
                print(f"❌ {description} thất bại!")
                print(f"Lỗi: {result.stderr}")
                return False
        except Exception as e:
            print(f"❌ Lỗi khi {description}: {e}")
            return False
    
    return True

def create_ipa():
    """Tạo IPA file cho TestFlight"""
    print("\n📦 Tạo IPA file...")
    
    # Tạo archive
    archive_cmd = [
        'xcodebuild', '-workspace', 'ios/Runner.xcworkspace',
        '-scheme', 'Runner', '-configuration', 'Release',
        '-archivePath', 'build/ios/Runner.xcarchive',
        'archive'
    ]
    
    try:
        result = subprocess.run(archive_cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Archive thành công!")
        else:
            print("❌ Archive thất bại!")
            print(f"Lỗi: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Lỗi khi tạo archive: {e}")
        return False
    
    # Export IPA
    export_cmd = [
        'xcodebuild', '-exportArchive',
        '-archivePath', 'build/ios/Runner.xcarchive',
        '-exportPath', 'build/ios/',
        '-exportOptionsPlist', 'ios/ExportOptions.plist'
    ]
    
    try:
        result = subprocess.run(export_cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ IPA export thành công!")
            print("📱 IPA file: build/ios/Runner.ipa")
            return True
        else:
            print("❌ IPA export thất bại!")
            print(f"Lỗi: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Lỗi khi export IPA: {e}")
        return False

def create_export_options():
    """Tạo file ExportOptions.plist"""
    print("\n📝 Tạo ExportOptions.plist...")
    
    export_options = {
        "method": "app-store",
        "teamID": "YOUR_TEAM_ID",
        "signingStyle": "automatic",
        "stripSwiftSymbols": True,
        "uploadBitcode": False,
        "uploadSymbols": True
    }
    
    export_path = "ios/ExportOptions.plist"
    try:
        import plistlib
        with open(export_path, 'wb') as f:
            plistlib.dump(export_options, f)
        print("✅ ExportOptions.plist đã tạo")
        print("⚠️  Hãy thay YOUR_TEAM_ID bằng Team ID của bạn")
        return True
    except Exception as e:
        print(f"❌ Lỗi tạo ExportOptions.plist: {e}")
        return False

def show_testflight_guide():
    """Hiển thị hướng dẫn upload TestFlight"""
    print("\n📋 HƯỚNG DẪN UPLOAD TESTFLIGHT:")
    print("1. Mở Xcode")
    print("2. Chọn Window > Organizer")
    print("3. Chọn tab 'Archives'")
    print("4. Chọn archive vừa tạo")
    print("5. Click 'Distribute App'")
    print("6. Chọn 'App Store Connect'")
    print("7. Chọn 'Upload'")
    print("8. Điền thông tin và upload")
    print("9. Kiểm tra App Store Connect > TestFlight")

def main():
    """Hàm chính"""
    print("🍎 BUILD IOS CHO TESTFLIGHT")
    print("=" * 50)
    
    # Kiểm tra môi trường
    if not check_ios_environment():
        print("\n❌ Môi trường iOS chưa sẵn sàng!")
        print("Cần:")
        print("- macOS")
        print("- Xcode")
        print("- iOS device hoặc simulator")
        return
    
    # Kiểm tra cấu hình Firebase
    if not check_firebase_ios_config():
        print("\n⚠️  Cần cấu hình Firebase iOS trước!")
        return
    
    # Tạo ExportOptions.plist
    create_export_options()
    
    # Build app
    if not build_ios_app():
        print("\n❌ Build thất bại!")
        return
    
    # Tạo IPA
    if not create_ipa():
        print("\n❌ Tạo IPA thất bại!")
        return
    
    print("\n🎉 BUILD THÀNH CÔNG!")
    print("📱 IPA file: build/ios/Runner.ipa")
    
    show_testflight_guide()

if __name__ == "__main__":
    main() 