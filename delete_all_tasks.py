#!/usr/bin/env python3
"""
Script để xóa toàn bộ tasks trong Firebase Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

def delete_all_tasks():
    """Xóa toàn bộ tasks trong collection 'tasks'"""
    
    try:
        # Khởi tạo Firebase Admin SDK
        if not firebase_admin._apps:
            # Sử dụng service account key nếu có
            if os.path.exists('serviceAccountKey.json'):
                cred = credentials.Certificate('serviceAccountKey.json')
                firebase_admin.initialize_app(cred)
                print("✅ Đã khởi tạo Firebase với service account key")
            else:
                # Sử dụng Application Default Credentials
                firebase_admin.initialize_app()
                print("✅ Đã khởi tạo Firebase với Application Default Credentials")
        
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

if __name__ == "__main__":
    main() 