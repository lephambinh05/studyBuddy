#!/usr/bin/env python3
"""
Script để import userId vào các document tasks hiện có trong Firebase Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

def import_userid_to_tasks():
    """Import userId vào các document tasks hiện có"""
    
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
        updated_count = 0
        
        print("🔍 Đang tìm tasks để import userId...")
        
        # Xử lý từng document
        for doc in docs:
            task_count += 1
            data = doc.to_dict()
            
            print(f"📋 Task {task_count}: {doc.id}")
            print(f"   Data hiện tại: {data}")
            
            # Kiểm tra xem đã có userId chưa
            if 'userId' not in data or data['userId'] is None:
                print(f"   ⚠️ Task này chưa có userId, thêm userId mặc định...")
                
                # Thêm userId mặc định (có thể thay đổi theo user thực tế)
                default_user_id = "5QP1IlDj4Wc1jmGKoH7WatUgJZf1"  # Thay đổi theo user ID thực tế
                
                # Cập nhật document với userId
                doc.reference.update({
                    'userId': default_user_id
                })
                
                print(f"   ✅ Đã thêm userId: {default_user_id}")
                updated_count += 1
            else:
                print(f"   ✅ Task đã có userId: {data['userId']}")
        
        print(f"✅ Hoàn thành! Đã kiểm tra {task_count} tasks, cập nhật {updated_count} tasks")
        
        # Kiểm tra lại
        print("🔍 Kiểm tra lại sau khi cập nhật...")
        updated_docs = tasks_ref.stream()
        for doc in updated_docs:
            data = doc.to_dict()
            print(f"   - Task {doc.id}: userId = {data.get('userId', 'N/A')}")
            
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return False
    
    return True

def main():
    print("🚀 Bắt đầu import userId vào tasks...")
    print("=" * 50)
    
    success = import_userid_to_tasks()
    
    print("=" * 50)
    if success:
        print("✅ Hoàn thành!")
    else:
        print("❌ Thất bại!")

if __name__ == "__main__":
    main() 