#!/usr/bin/env python3
"""
Script để import data vào Firebase cho ứng dụng StudyBuddy
Sử dụng: python scripts/import_data.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json
import datetime
from typing import Dict, List, Any
import os
import sys

# Thêm thư mục gốc vào path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class StudyBuddyDataImporter:
    def __init__(self, service_account_path: str = None):
        """
        Khởi tạo importer với Firebase credentials
        """
        try:
            if service_account_path and os.path.exists(service_account_path):
                # Sử dụng service account file
                print(f"🔑 Đang sử dụng Service Account: {service_account_path}")
                cred = credentials.Certificate(service_account_path)
                firebase_admin.initialize_app(cred)
            else:
                # Sử dụng default credentials (cho local development)
                print("🔑 Đang sử dụng Application Default Credentials...")
                firebase_admin.initialize_app()
            
            self.db = firestore.client()
            print("✅ Đã kết nối Firebase thành công!")
            
        except Exception as e:
            print(f"❌ Lỗi kết nối Firebase: {str(e)}")
            print("\n🔧 Hướng dẫn khắc phục:")
            print("1. Tạo Service Account Key:")
            print("   - Vào Firebase Console > Project Settings > Service Accounts")
            print("   - Click 'Generate new private key'")
            print("   - Tải file JSON về và đặt trong thư mục scripts/")
            print("   - Cập nhật đường dẫn trong script")
            print("\n2. Hoặc sử dụng Google Cloud CLI:")
            print("   - Cài đặt Google Cloud CLI")
            print("   - Chạy: gcloud auth application-default login")
            raise e

    def import_tasks(self, tasks_data: List[Dict[str, Any]]):
        """
        Import danh sách tasks vào Firestore
        """
        print(f"📝 Đang import {len(tasks_data)} tasks...")
        
        batch = self.db.batch()
        tasks_ref = self.db.collection('tasks')
        
        for task_data in tasks_data:
            # Tạo document ID mới
            doc_ref = tasks_ref.document()
            
            # Chuẩn bị data cho Firestore
            firestore_data = {
                'id': doc_ref.id,
                'title': task_data['title'],
                'description': task_data.get('description'),
                'subject': task_data['subject'],
                'deadline': task_data['deadline'],
                'isCompleted': task_data['isCompleted'],
                'priority': task_data['priority'],
                'createdAt': task_data['createdAt'],
                'completedAt': task_data.get('completedAt')
            }
            
            batch.set(doc_ref, firestore_data)
        
        # Commit batch
        batch.commit()
        print(f"✅ Đã import {len(tasks_data)} tasks thành công!")

    def import_events(self, events_data: List[Dict[str, Any]]):
        """
        Import danh sách events vào Firestore
        """
        print(f"📅 Đang import {len(events_data)} events...")
        
        batch = self.db.batch()
        events_ref = self.db.collection('events')
        
        for event_data in events_data:
            # Tạo document ID mới
            doc_ref = events_ref.document()
            
            # Chuẩn bị data cho Firestore
            firestore_data = {
                'id': doc_ref.id,
                'title': event_data['title'],
                'description': event_data.get('description'),
                'startTime': event_data['startTime'],
                'endTime': event_data['endTime'],
                'type': event_data['type'],
                'subject': event_data.get('subject'),
                'location': event_data.get('location'),
                'isAllDay': event_data['isAllDay'],
                'color': event_data['color']
            }
            
            batch.set(doc_ref, firestore_data)
        
        # Commit batch
        batch.commit()
        print(f"✅ Đã import {len(events_data)} events thành công!")

    def import_users(self, users_data: List[Dict[str, Any]]):
        """
        Import danh sách users vào Firestore
        """
        print(f"👤 Đang import {len(users_data)} users...")
        
        batch = self.db.batch()
        users_ref = self.db.collection('users')
        
        for user_data in users_data:
            # Tạo document ID mới
            doc_ref = users_ref.document()
            
            # Chuẩn bị data cho Firestore
            firestore_data = {
                'id': doc_ref.id,
                'name': user_data['name'],
                'email': user_data['email'],
                'avatar': user_data.get('avatar'),
                'grade': user_data.get('grade'),
                'school': user_data.get('school'),
                'createdAt': user_data['createdAt'],
                'lastLoginAt': user_data.get('lastLoginAt')
            }
            
            batch.set(doc_ref, firestore_data)
        
        # Commit batch
        batch.commit()
        print(f"✅ Đã import {len(users_data)} users thành công!")

    def clear_collection(self, collection_name: str):
        """
        Xóa tất cả documents trong collection
        """
        print(f"🗑️ Đang xóa collection '{collection_name}'...")
        
        docs = self.db.collection(collection_name).stream()
        batch = self.db.batch()
        
        for doc in docs:
            batch.delete(doc.reference)
        
        batch.commit()
        print(f"✅ Đã xóa collection '{collection_name}' thành công!")

    def get_sample_data(self) -> Dict[str, List[Dict[str, Any]]]:
        """
        Tạo sample data cho ứng dụng
        """
        now = datetime.datetime.now()
        
        # Sample Tasks
        tasks = [
            {
                'title': 'Làm bài tập Toán chương 3',
                'description': 'Hoàn thành các bài tập từ trang 45-50 trong sách giáo khoa',
                'subject': 'Toán',
                'deadline': (now + datetime.timedelta(days=2)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=1)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Ôn tập từ vựng tiếng Anh',
                'description': 'Học 50 từ mới trong Unit 5 và làm bài tập vocabulary',
                'subject': 'Anh',
                'deadline': (now + datetime.timedelta(days=1)).isoformat(),
                'isCompleted': True,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=2)).isoformat(),
                'completedAt': (now - datetime.timedelta(hours=2)).isoformat()
            },
            {
                'title': 'Đọc sách Văn học',
                'description': 'Đọc và phân tích tác phẩm "Truyện Kiều" của Nguyễn Du',
                'subject': 'Văn',
                'deadline': (now + datetime.timedelta(days=3)).isoformat(),
                'isCompleted': False,
                'priority': 3,
                'createdAt': (now - datetime.timedelta(days=3)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Làm thí nghiệm Hóa học',
                'description': 'Thực hành thí nghiệm về phản ứng oxi hóa khử trong phòng lab',
                'subject': 'Hóa',
                'deadline': (now - datetime.timedelta(days=1)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=4)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Học lý thuyết Vật lý',
                'description': 'Ôn tập chương điện học và từ học, chuẩn bị cho bài kiểm tra',
                'subject': 'Lý',
                'deadline': (now + datetime.timedelta(days=5)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=5)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Làm bài tập Sinh học',
                'description': 'Hoàn thành bài tập về hệ tuần hoàn và hệ hô hấp',
                'subject': 'Sinh',
                'deadline': (now + datetime.timedelta(days=4)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=1)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Ôn tập Lịch sử',
                'description': 'Học thuộc các sự kiện lịch sử Việt Nam thời kỳ 1945-1975',
                'subject': 'Sử',
                'deadline': (now + datetime.timedelta(days=6)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=2)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Làm bài tập Địa lý',
                'description': 'Phân tích biểu đồ khí hậu và địa hình các vùng miền',
                'subject': 'Địa',
                'deadline': (now + datetime.timedelta(days=7)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=3)).isoformat(),
                'completedAt': None
            }
        ]

        # Sample Events
        events = [
            {
                'title': 'Học Toán',
                'description': 'Ôn tập chương 3 về đạo hàm và ứng dụng',
                'startTime': (now + datetime.timedelta(hours=2)).isoformat(),
                'endTime': (now + datetime.timedelta(hours=4)).isoformat(),
                'type': 'study',
                'subject': 'Toán',
                'location': 'Thư viện trường',
                'isAllDay': False,
                'color': '#FF6B6B'
            },
            {
                'title': 'Kiểm tra Văn',
                'description': 'Kiểm tra 15 phút về tác phẩm văn học',
                'startTime': (now + datetime.timedelta(days=1, hours=8)).isoformat(),
                'endTime': (now + datetime.timedelta(days=1, hours=8, minutes=15)).isoformat(),
                'type': 'exam',
                'subject': 'Văn',
                'location': 'Lớp 12A1',
                'isAllDay': False,
                'color': '#4ECDC4'
            },
            {
                'title': 'Nhóm học tập',
                'description': 'Thảo luận nhóm về bài tập Hóa học',
                'startTime': (now + datetime.timedelta(days=2, hours=14)).isoformat(),
                'endTime': (now + datetime.timedelta(days=2, hours=16)).isoformat(),
                'type': 'study',
                'subject': 'Hóa',
                'location': 'Phòng học nhóm',
                'isAllDay': False,
                'color': '#45B7D1'
            },
            {
                'title': 'Thi thử Đại học',
                'description': 'Làm bài thi thử môn Toán và Văn',
                'startTime': (now + datetime.timedelta(days=3, hours=7)).isoformat(),
                'endTime': (now + datetime.timedelta(days=3, hours=11)).isoformat(),
                'type': 'exam',
                'subject': None,
                'location': 'Hội trường trường',
                'isAllDay': False,
                'color': '#96CEB4'
            },
            {
                'title': 'Dã ngoại học tập',
                'description': 'Tham quan bảo tàng lịch sử và địa lý',
                'startTime': (now + datetime.timedelta(days=5, hours=8)).isoformat(),
                'endTime': (now + datetime.timedelta(days=5, hours=17)).isoformat(),
                'type': 'other',
                'subject': None,
                'location': 'Bảo tàng Lịch sử Việt Nam',
                'isAllDay': True,
                'color': '#FFEAA7'
            }
        ]

        # Sample Users
        users = [
            {
                'name': 'Nguyễn Văn An',
                'email': 'an.nguyen@example.com',
                'avatar': 'https://example.com/avatar1.jpg',
                'grade': '12',
                'school': 'THPT Chuyên Hà Nội - Amsterdam',
                'createdAt': (now - datetime.timedelta(days=30)).isoformat(),
                'lastLoginAt': now.isoformat()
            },
            {
                'name': 'Trần Thị Bình',
                'email': 'binh.tran@example.com',
                'avatar': 'https://example.com/avatar2.jpg',
                'grade': '12',
                'school': 'THPT Chuyên Hà Nội - Amsterdam',
                'createdAt': (now - datetime.timedelta(days=25)).isoformat(),
                'lastLoginAt': (now - datetime.timedelta(hours=2)).isoformat()
            },
            {
                'name': 'Lê Hoàng Cường',
                'email': 'cuong.le@example.com',
                'avatar': 'https://example.com/avatar3.jpg',
                'grade': '12',
                'school': 'THPT Chuyên Hà Nội - Amsterdam',
                'createdAt': (now - datetime.timedelta(days=20)).isoformat(),
                'lastLoginAt': (now - datetime.timedelta(hours=5)).isoformat()
            }
        ]

        return {
            'tasks': tasks,
            'events': events,
            'users': users
        }

def main():
    """
    Main function để chạy script import data
    """
    print("🚀 Bắt đầu import data vào Firebase...")
    print("=" * 50)
    
    # Khởi tạo importer
    # Nếu có file service account, thay đổi đường dẫn ở đây
    service_account_path = None  # "path/to/serviceAccountKey.json"
    
    # Kiểm tra xem có file service account trong thư mục hiện tại không
    current_dir = os.path.dirname(os.path.abspath(__file__))
    possible_keys = [
        os.path.join(current_dir, "serviceAccountKey.json"),
        os.path.join(current_dir, "firebase-key.json"),
        os.path.join(current_dir, "firebase-credentials.json"),
        os.path.join(current_dir, "studybuddy-8bfaa-firebase-adminsdk-fbsvc-76aae6727d.json"),
    ]
    
    for key_path in possible_keys:
        if os.path.exists(key_path):
            service_account_path = key_path
            print(f"🔑 Tìm thấy Service Account key: {key_path}")
            break
    
    try:
        importer = StudyBuddyDataImporter(service_account_path)
        
        # Lấy sample data
        sample_data = importer.get_sample_data()
        
        # Hỏi user có muốn xóa data cũ không
        clear_old = input("🗑️ Có muốn xóa data cũ không? (y/N): ").lower().strip() == 'y'
        
        if clear_old:
            print("🗑️ Đang xóa data cũ...")
            importer.clear_collection('tasks')
            importer.clear_collection('events')
            importer.clear_collection('users')
            print("✅ Đã xóa data cũ thành công!")
        
        # Import data
        print("\n📊 Bắt đầu import data...")
        importer.import_tasks(sample_data['tasks'])
        importer.import_events(sample_data['events'])
        importer.import_users(sample_data['users'])
        
        print("\n🎉 Import data thành công!")
        print("=" * 50)
        print("📝 Đã import:")
        print(f"   - {len(sample_data['tasks'])} tasks")
        print(f"   - {len(sample_data['events'])} events")
        print(f"   - {len(sample_data['users'])} users")
        print("=" * 50)
        
    except Exception as e:
        print(f"❌ Lỗi: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 