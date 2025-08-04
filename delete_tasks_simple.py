#!/usr/bin/env python3
"""
Script đơn giản để xóa toàn bộ tasks trong Firebase Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore

def delete_all_tasks():
    """Xóa toàn bộ tasks trong collection 'tasks'"""
    
    try:
        # Khởi tạo Firebase Admin SDK với project ID
        if not firebase_admin._apps:
            # Sử dụng service account key nếu có
            try:
                import os
                if os.path.exists('serviceAccountKey.json'):
                    cred = credentials.Certificate('serviceAccountKey.json')
                    firebase_admin.initialize_app(cred)
                    print("✅ Đã khởi tạo Firebase với service account key")
                else:
                    # Sử dụng project ID trực tiếp
                    firebase_admin.initialize_app(options={
                        'projectId': 'studybuddy-8bfaa'
                    })
                    print("✅ Đã khởi tạo Firebase với project ID")
            except Exception as e:
                print(f"❌ Lỗi khởi tạo Firebase: {e}")
                print("💡 Hãy tạo file serviceAccountKey.json từ Firebase Console")
                return False
        
        # Lấy Firestore client
        db = firestore.client()
        print("✅ Đã kết nối Firestore")
        
        # Lấy collection 'tasks'
        tasks_ref = db.collection('tasks')
        
        # Lấy tất cả documents
        docs = tasks_ref.stream()
        task_count = 0
        
        print("🔍 Đang tìm tasks để xóa...")
        
        # Xóa từng document
        for doc in docs:
            print(f"🗑️ Đang xóa task: {doc.id}")
            print(f"   Data: {doc.to_dict()}")
            doc.reference.delete()
            task_count += 1
        
        print(f"✅ Đã xóa thành công {task_count} tasks!")
        
        # Kiểm tra lại
        remaining_docs = tasks_ref.stream()
        remaining_count = sum(1 for _ in remaining_docs)
        
        if remaining_count == 0:
            print("✅ Collection 'tasks' đã trống!")
        else:
            print(f"⚠️ Vẫn còn {remaining_count} tasks (có thể do lỗi)")
            
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return False
    
    return True

def main():
    print("🚀 Bắt đầu xóa toàn bộ tasks...")
    print("=" * 50)
    
    success = delete_all_tasks()
    
    print("=" * 50)
    if success:
        print("✅ Hoàn thành!")
    else:
        print("❌ Thất bại!")
        print("\n💡 Hướng dẫn tạo service account key:")
        print("1. Vào Firebase Console: https://console.firebase.google.com")
        print("2. Chọn project: studybuddy-8bfaa")
        print("3. Vào Settings > Service accounts")
        print("4. Click 'Generate new private key'")
        print("5. Tải file JSON và đổi tên thành 'serviceAccountKey.json'")
        print("6. Đặt file trong thư mục này")

if __name__ == "__main__":
    main() 