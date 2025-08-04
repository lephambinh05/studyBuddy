# Hướng dẫn Import UserId vào Tasks

## 🔧 Cách 1: Firebase Console (Khuyến nghị)

### Bước 1: Vào Firebase Console
1. Mở: https://console.firebase.google.com/project/studybuddy-8bfaa/firestore
2. Chọn **"Data"** tab

### Bước 2: Cập nhật từng document
1. Click vào document task cần cập nhật
2. Click **"+ Add field"**
3. Thêm field: `userId` với value: `"5QP1IlDj4Wc1jmGKoH7WatUgJZf1"`
4. Click **"Update"**

### Bước 3: Lặp lại cho tất cả tasks
- Cập nhật tất cả tasks chưa có `userId`

## 🔧 Cách 2: Service Account Key

### Bước 1: Tạo Service Account Key
1. Vào: https://console.firebase.google.com/project/studybuddy-8bfaa/settings/serviceaccounts
2. Click **"Generate new private key"**
3. Tải file JSON về
4. Đổi tên thành: `serviceAccountKey.json`
5. Đặt trong thư mục project

### Bước 2: Chạy script
```bash
python import_userid.py
```

## 🔧 Cách 3: Cập nhật trực tiếp trong code

### Bước 1: Sửa TaskRepository
- Đã cập nhật `toggleTaskCompletion()` để thêm `userId` khi update
- Đã cập nhật `addTask()` để thêm `userId` khi tạo mới

### Bước 2: Test trong app
1. Tạo task mới → Sẽ có `userId`
2. Toggle completion → Sẽ cập nhật `userId`

## 📊 UserId cần sử dụng:
```
"5QP1IlDj4Wc1jmGKoH7WatUgJZf1"
```

## ✅ Kết quả mong đợi:
- Tất cả tasks đều có `userId`
- Toggle completion hoạt động đúng
- Tasks chỉ hiển thị cho user đúng
- Không tạo document mới khi toggle 