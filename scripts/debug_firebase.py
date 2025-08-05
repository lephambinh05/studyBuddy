#!/usr/bin/env python3
"""
Script debug Firebase trên thiết bị thật
"""

import subprocess
import time
import os

def check_device_connection():
    """Kiểm tra kết nối thiết bị"""
    print("🔍 Kiểm tra kết nối thiết bị...")
    
    try:
        result = subprocess.run(['flutter', 'devices'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Thiết bị đã kết nối:")
            print(result.stdout)
            return True
        else:
            print("❌ Không thể kiểm tra thiết bị")
            return False
    except Exception as e:
        print(f"❌ Lỗi kiểm tra thiết bị: {e}")
        return False

def run_app_with_logs():
    """Chạy app với log chi tiết"""
    print("\n🚀 Chạy app với log chi tiết...")
    print("⚠️  Lưu ý: Đóng app này để xem log Firebase")
    print("📱 Mở app StudyBuddy trên thiết bị và thử các tính năng Firebase")
    print("🔍 Xem log bên dưới để debug...")
    print("=" * 50)
    
    try:
        # Chạy app với verbose logging
        subprocess.run([
            'flutter', 'run', 
            '--device-id=N0AA003668K52601992',
            '-v'
        ])
    except KeyboardInterrupt:
        print("\n⏹️  Dừng debug...")
    except Exception as e:
        print(f"❌ Lỗi khi chạy app: {e}")

def check_firebase_logs():
    """Kiểm tra log Firebase"""
    print("\n📊 KIỂM TRA LOG FIREBASE:")
    print("1. Mở Firebase Console: https://console.firebase.google.com")
    print("2. Chọn project: studybuddy-8bfaa")
    print("3. Vào Analytics > Events để xem hoạt động")
    print("4. Vào Crashlytics để xem lỗi (nếu có)")
    print("5. Vào Authentication để xem đăng nhập")
    print("6. Vào Firestore để xem dữ liệu")

def show_debug_tips():
    """Hiển thị tips debug"""
    print("\n💡 TIPS DEBUG FIREBASE:")
    print("1. Đảm bảo thiết bị có kết nối internet")
    print("2. Kiểm tra Google Play Services đã cập nhật")
    print("3. Thử đăng nhập/đăng ký để test Authentication")
    print("4. Thử tạo task để test Firestore")
    print("5. Kiểm tra notification settings")
    print("6. Nếu lỗi, hãy restart app và thử lại")

def main():
    """Hàm chính"""
    print("🔧 DEBUG FIREBASE TRÊN THIẾT BỊ THẬT")
    print("=" * 50)
    
    # Kiểm tra thiết bị
    if not check_device_connection():
        print("❌ Không có thiết bị kết nối!")
        print("Hãy kết nối thiết bị Android và thử lại")
        return
    
    print("\n✅ Thiết bị đã sẵn sàng!")
    
    # Hiển thị menu
    while True:
        print("\n📋 MENU DEBUG:")
        print("1. Chạy app với log chi tiết")
        print("2. Kiểm tra Firebase Console")
        print("3. Xem tips debug")
        print("4. Thoát")
        
        choice = input("\nChọn option (1-4): ").strip()
        
        if choice == "1":
            run_app_with_logs()
        elif choice == "2":
            check_firebase_logs()
        elif choice == "3":
            show_debug_tips()
        elif choice == "4":
            print("👋 Tạm biệt!")
            break
        else:
            print("❌ Lựa chọn không hợp lệ!")

if __name__ == "__main__":
    main() 