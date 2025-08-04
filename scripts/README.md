# StudyBuddy Data Import Scripts

Scripts để import sample data vào Firebase cho ứng dụng StudyBuddy.

## 📁 Cấu trúc thư mục

```
scripts/
├── import_data.py          # Script Python chính
├── import_data.bat         # Script Windows
├── import_data.sh          # Script Linux/Mac
├── requirements.txt         # Python dependencies
├── sample_data.json        # Sample data JSON
└── README.md              # Hướng dẫn này
```

## 🚀 Cách sử dụng

### Phương pháp 1: Sử dụng script tự động

#### Windows
```bash
cd scripts
import_data.bat
```

#### Linux/Mac
```bash
cd scripts
chmod +x import_data.sh
./import_data.sh
```

### Phương pháp 2: Chạy trực tiếp Python

```bash
cd scripts
pip install -r requirements.txt
python import_data.py
```

## ⚙️ Cấu hình Firebase

### 1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project có sẵn
3. Bật Firestore Database

### 2. Cấu hình Authentication

#### Option A: Sử dụng Service Account (Recommended)

1. Vào Firebase Console > Project Settings > Service Accounts
2. Click "Generate new private key"
3. Tải file JSON về và đặt trong thư mục `scripts/`
4. Cập nhật đường dẫn trong `import_data.py`:

```python
service_account_path = "path/to/your/serviceAccountKey.json"
```

#### Option B: Sử dụng Google Cloud CLI

1. Cài đặt [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
2. Chạy lệnh:
```bash
gcloud auth application-default login
```

### 3. Cấu hình Firestore Rules

Trong Firebase Console > Firestore Database > Rules, thêm rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Cho development
    }
  }
}
```

## 📊 Sample Data

Script sẽ import các loại data sau:

### Tasks (8 items)
- Bài tập Toán, Văn, Anh, Lý, Hóa, Sinh, Sử, Địa
- Có các mức độ ưu tiên khác nhau
- Một số đã hoàn thành, một số chưa

### Events (5 items)
- Học tập, kiểm tra, dã ngoại
- Có thời gian bắt đầu và kết thúc
- Màu sắc khác nhau cho từng loại

### Users (3 items)
- Thông tin học sinh mẫu
- Avatar và thông tin cá nhân

## 🔧 Tùy chỉnh

### Thêm data mới

1. Chỉnh sửa `sample_data.json` hoặc `import_data.py`
2. Thêm fields mới vào data structure
3. Chạy lại script

### Thay đổi cấu trúc data

1. Cập nhật models trong Flutter app
2. Cập nhật script import
3. Cập nhật Firestore rules nếu cần

## 🛠️ Troubleshooting

### Lỗi Authentication
```
❌ Lỗi: Permission denied
```
**Giải pháp:**
- Kiểm tra Service Account key
- Đảm bảo project ID đúng
- Kiểm tra Firestore rules

### Lỗi Network
```
❌ Lỗi: Connection timeout
```
**Giải pháp:**
- Kiểm tra kết nối internet
- Thử lại sau vài phút
- Kiểm tra firewall

### Lỗi Python
```
❌ Lỗi: Module not found
```
**Giải pháp:**
```bash
pip install firebase-admin google-cloud-firestore google-auth
```

## 📝 Logs

Script sẽ hiển thị:
- ✅ Kết nối Firebase thành công
- 📝 Đang import X tasks...
- 📅 Đang import X events...
- 👤 Đang import X users...
- 🎉 Import data thành công!

## 🔄 Reset Data

Script hỏi có muốn xóa data cũ không:
```
🗑️ Có muốn xóa data cũ không? (y/N):
```

- `y`: Xóa tất cả data cũ trước khi import
- `N`: Thêm data mới vào data hiện có

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Đảm bảo Firebase project đã được cấu hình đúng
3. Kiểm tra network connection
4. Thử chạy lại script

## 🎯 Kết quả mong đợi

Sau khi chạy script thành công:
- 8 tasks được thêm vào collection `tasks`
- 5 events được thêm vào collection `events`
- 3 users được thêm vào collection `users`
- Data có thể được xem trong Firebase Console
- Flutter app có thể load data từ Firebase 