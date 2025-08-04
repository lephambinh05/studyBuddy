#!/usr/bin/env python3
"""
Script để deploy ứng dụng StudyBuddy với real data
Sử dụng: python scripts/deploy_production.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json
import datetime
import os
import sys
from typing import Dict, List, Any

class StudyBuddyDeployer:
    def __init__(self, service_account_path: str):
        """
        Khởi tạo deployer với Firebase credentials
        """
        if not os.path.exists(service_account_path):
            raise FileNotFoundError(f"Service Account key không tồn tại: {service_account_path}")
        
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()
        print("✅ Đã kết nối Firebase Production thành công!")

    def backup_current_data(self) -> Dict[str, Any]:
        """
        Backup data hiện tại trước khi deploy
        """
        print("📦 Đang backup data hiện tại...")
        
        backup = {
            'tasks': [],
            'events': [],
            'users': [],
            'timestamp': datetime.datetime.now().isoformat(),
            'backup_type': 'pre_deploy'
        }
        
        try:
            # Backup tasks
            try:
                tasks = self.db.collection('tasks').get()
                backup['tasks'] = [doc.to_dict() for doc in tasks.docs]
                print(f"✅ Backup {len(backup['tasks'])} tasks")
            except Exception as e:
                print(f"⚠️ Không có tasks để backup: {e}")
            
            # Backup events
            try:
                events = self.db.collection('events').get()
                backup['events'] = [doc.to_dict() for doc in events.docs]
                print(f"✅ Backup {len(backup['events'])} events")
            except Exception as e:
                print(f"⚠️ Không có events để backup: {e}")
            
            # Backup users
            try:
                users = self.db.collection('users').get()
                backup['users'] = [doc.to_dict() for doc in users.docs]
                print(f"✅ Backup {len(backup['users'])} users")
            except Exception as e:
                print(f"⚠️ Không có users để backup: {e}")
            
            # Lưu backup
            backup_file = f"backup_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            with open(backup_file, 'w', encoding='utf-8') as f:
                json.dump(backup, f, ensure_ascii=False, indent=2)
            
            print(f"✅ Backup đã lưu vào: {backup_file}")
            return backup
            
        except Exception as e:
            print(f"❌ Lỗi backup: {e}")
            raise e

    def deploy_production_data(self, data_file: str = None):
        """
        Deploy production data
        """
        print("🚀 Bắt đầu deploy production data...")
        
        # Backup trước khi deploy
        self.backup_current_data()
        
        # Load production data
        if data_file and os.path.exists(data_file):
            with open(data_file, 'r', encoding='utf-8') as f:
                production_data = json.load(f)
        else:
            production_data = self.get_production_data()
        
        # Clear existing data
        print("🗑️ Đang xóa data cũ...")
        self.clear_collection('tasks')
        self.clear_collection('events')
        self.clear_collection('users')
        
        # Deploy new data
        print("📊 Đang deploy production data...")
        self.import_tasks(production_data['tasks'])
        self.import_events(production_data['events'])
        self.import_users(production_data['users'])
        
        print("🎉 Deploy production thành công!")

    def get_production_data(self) -> Dict[str, List[Dict[str, Any]]]:
        """
        Tạo production data với dữ liệu thực tế
        """
        now = datetime.datetime.now()
        
        # Production Tasks - Dữ liệu thực tế hơn
        tasks = [
            {
                'title': 'Hoàn thành bài tập Toán chương 3 - Đạo hàm',
                'description': 'Làm bài tập từ trang 45-50, bài 1-10 trong sách giáo khoa Đại số 12',
                'subject': 'Toán',
                'deadline': (now + datetime.timedelta(days=3)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=2)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Ôn tập từ vựng tiếng Anh Unit 5 - Technology',
                'description': 'Học 50 từ mới về công nghệ, làm bài tập vocabulary và grammar',
                'subject': 'Anh',
                'deadline': (now + datetime.timedelta(days=2)).isoformat(),
                'isCompleted': True,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=5)).isoformat(),
                'completedAt': (now - datetime.timedelta(hours=4)).isoformat()
            },
            {
                'title': 'Phân tích tác phẩm "Truyện Kiều" - Nguyễn Du',
                'description': 'Đọc và phân tích các đoạn trích, chuẩn bị cho bài kiểm tra văn học',
                'subject': 'Văn',
                'deadline': (now + datetime.timedelta(days=5)).isoformat(),
                'isCompleted': False,
                'priority': 3,
                'createdAt': (now - datetime.timedelta(days=1)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Thí nghiệm Hóa học - Phản ứng oxi hóa khử',
                'description': 'Thực hành thí nghiệm trong phòng lab, viết báo cáo thí nghiệm',
                'subject': 'Hóa',
                'deadline': (now + datetime.timedelta(days=1)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=3)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Ôn tập Vật lý - Chương điện học và từ học',
                'description': 'Học lý thuyết và làm bài tập về điện trường, từ trường',
                'subject': 'Lý',
                'deadline': (now + datetime.timedelta(days=4)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=2)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Bài tập Sinh học - Hệ tuần hoàn và hô hấp',
                'description': 'Hoàn thành bài tập về cấu tạo và chức năng hệ tuần hoàn',
                'subject': 'Sinh',
                'deadline': (now + datetime.timedelta(days=6)).isoformat(),
                'isCompleted': False,
                'priority': 2,
                'createdAt': (now - datetime.timedelta(days=1)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Ôn tập Lịch sử - Việt Nam 1945-1975',
                'description': 'Học thuộc các sự kiện lịch sử quan trọng, chuẩn bị cho bài kiểm tra',
                'subject': 'Sử',
                'deadline': (now + datetime.timedelta(days=7)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=3)).isoformat(),
                'completedAt': None
            },
            {
                'title': 'Phân tích biểu đồ Địa lý - Khí hậu và địa hình',
                'description': 'Làm bài tập phân tích biểu đồ khí hậu các vùng miền Việt Nam',
                'subject': 'Địa',
                'deadline': (now + datetime.timedelta(days=8)).isoformat(),
                'isCompleted': False,
                'priority': 1,
                'createdAt': (now - datetime.timedelta(days=2)).isoformat(),
                'completedAt': None
            }
        ]

        # Production Events - Sự kiện thực tế
        events = [
            {
                'title': 'Học nhóm Toán - Ôn tập đạo hàm',
                'description': 'Thảo luận nhóm về các dạng bài tập đạo hàm và ứng dụng',
                'startTime': (now + datetime.timedelta(hours=2)).isoformat(),
                'endTime': (now + datetime.timedelta(hours=4)).isoformat(),
                'type': 'study',
                'subject': 'Toán',
                'location': 'Thư viện trường',
                'isAllDay': False,
                'color': '#FF6B6B'
            },
            {
                'title': 'Kiểm tra 15 phút Văn học',
                'description': 'Kiểm tra về tác phẩm "Truyện Kiều" của Nguyễn Du',
                'startTime': (now + datetime.timedelta(days=1, hours=8)).isoformat(),
                'endTime': (now + datetime.timedelta(days=1, hours=8, minutes=15)).isoformat(),
                'type': 'exam',
                'subject': 'Văn',
                'location': 'Lớp 12A1',
                'isAllDay': False,
                'color': '#4ECDC4'
            },
            {
                'title': 'Thí nghiệm Hóa học - Phòng lab',
                'description': 'Thực hành thí nghiệm phản ứng oxi hóa khử',
                'startTime': (now + datetime.timedelta(days=2, hours=14)).isoformat(),
                'endTime': (now + datetime.timedelta(days=2, hours=16)).isoformat(),
                'type': 'study',
                'subject': 'Hóa',
                'location': 'Phòng thí nghiệm Hóa học',
                'isAllDay': False,
                'color': '#45B7D1'
            },
            {
                'title': 'Thi thử Đại học - Toán và Văn',
                'description': 'Làm bài thi thử môn Toán và Văn theo cấu trúc đề thi THPT Quốc gia',
                'startTime': (now + datetime.timedelta(days=3, hours=7)).isoformat(),
                'endTime': (now + datetime.timedelta(days=3, hours=11)).isoformat(),
                'type': 'exam',
                'subject': None,
                'location': 'Hội trường trường',
                'isAllDay': False,
                'color': '#96CEB4'
            },
            {
                'title': 'Dã ngoại học tập - Bảo tàng Lịch sử',
                'description': 'Tham quan bảo tàng lịch sử và địa lý để học tập thực tế',
                'startTime': (now + datetime.timedelta(days=5, hours=8)).isoformat(),
                'endTime': (now + datetime.timedelta(days=5, hours=17)).isoformat(),
                'type': 'other',
                'subject': None,
                'location': 'Bảo tàng Lịch sử Việt Nam',
                'isAllDay': True,
                'color': '#FFEAA7'
            }
        ]

        # Production Users - Thông tin thực tế
        users = [
            {
                'name': 'Nguyễn Văn An',
                'email': 'an.nguyen@student.edu.vn',
                'avatar': 'https://example.com/avatar1.jpg',
                'grade': '12',
                'school': 'THPT Chuyên Hà Nội - Amsterdam',
                'createdAt': (now - datetime.timedelta(days=30)).isoformat(),
                'lastLoginAt': now.isoformat()
            },
            {
                'name': 'Trần Thị Bình',
                'email': 'binh.tran@student.edu.vn',
                'avatar': 'https://example.com/avatar2.jpg',
                'grade': '12',
                'school': 'THPT Chuyên Hà Nội - Amsterdam',
                'createdAt': (now - datetime.timedelta(days=25)).isoformat(),
                'lastLoginAt': (now - datetime.timedelta(hours=2)).isoformat()
            },
            {
                'name': 'Lê Hoàng Cường',
                'email': 'cuong.le@student.edu.vn',
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

    def import_tasks(self, tasks_data: List[Dict[str, Any]]):
        """Import tasks"""
        print(f"📝 Đang import {len(tasks_data)} production tasks...")
        batch = self.db.batch()
        tasks_ref = self.db.collection('tasks')
        
        for task_data in tasks_data:
            doc_ref = tasks_ref.document()
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
        
        batch.commit()
        print(f"✅ Đã import {len(tasks_data)} production tasks thành công!")

    def import_events(self, events_data: List[Dict[str, Any]]):
        """Import events"""
        print(f"📅 Đang import {len(events_data)} production events...")
        batch = self.db.batch()
        events_ref = self.db.collection('events')
        
        for event_data in events_data:
            doc_ref = events_ref.document()
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
        
        batch.commit()
        print(f"✅ Đã import {len(events_data)} production events thành công!")

    def import_users(self, users_data: List[Dict[str, Any]]):
        """Import users"""
        print(f"👤 Đang import {len(users_data)} production users...")
        batch = self.db.batch()
        users_ref = self.db.collection('users')
        
        for user_data in users_data:
            doc_ref = users_ref.document()
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
        
        batch.commit()
        print(f"✅ Đã import {len(users_data)} production users thành công!")

    def clear_collection(self, collection_name: str):
        """Clear collection"""
        print(f"🗑️ Đang xóa collection '{collection_name}'...")
        docs = self.db.collection(collection_name).stream()
        batch = self.db.batch()
        
        for doc in docs:
            batch.delete(doc.reference)
        
        batch.commit()
        print(f"✅ Đã xóa collection '{collection_name}' thành công!")

def main():
    """Main function"""
    print("🚀 StudyBuddy Production Deploy Script")
    print("=" * 50)
    
    # Kiểm tra Service Account key
    service_account_path = "studybuddy-8bfaa-firebase-adminsdk-fbsvc-76aae6727d.json"
    
    if not os.path.exists(service_account_path):
        print(f"❌ Không tìm thấy Service Account key: {service_account_path}")
        print("📝 Vui lòng đặt file Service Account key trong thư mục scripts/")
        sys.exit(1)
    
    try:
        # Khởi tạo deployer
        deployer = StudyBuddyDeployer(service_account_path)
        
        # Hỏi user có muốn deploy không
        deploy = input("🚀 Có muốn deploy production data không? (y/N): ").lower().strip() == 'y'
        
        if deploy:
            # Hỏi có muốn sử dụng file data tùy chỉnh không
            custom_data = input("📁 Có muốn sử dụng file data tùy chỉnh không? (y/N): ").lower().strip() == 'y'
            
            data_file = None
            if custom_data:
                data_file = input("📂 Nhập đường dẫn file data (JSON): ").strip()
                if not os.path.exists(data_file):
                    print(f"❌ File không tồn tại: {data_file}")
                    data_file = None
            
            # Deploy production data
            deployer.deploy_production_data(data_file)
            
            print("\n🎉 Deploy production thành công!")
            print("=" * 50)
            print("📊 Production data đã được deploy:")
            print("   - 8 production tasks")
            print("   - 5 production events") 
            print("   - 3 production users")
            print("=" * 50)
        else:
            print("❌ Hủy deploy")
            
    except Exception as e:
        print(f"❌ Lỗi deploy: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 