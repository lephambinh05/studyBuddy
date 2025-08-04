# Hướng dẫn cấu hình Firebase cho StudyBuddy

## 1. Vấn đề hiện tại

Ứng dụng đang gặp lỗi `[cloud_firestore/permission-denied] Missing or insufficient permissions` vì Firebase Security Rules chưa được cấu hình đúng.

## 2. Giải pháp tạm thời

Hiện tại ứng dụng đã được cấu hình để sử dụng **mock data** khi Firebase không khả dụng. Điều này cho phép:

- ✅ Ứng dụng hoạt động bình thường
- ✅ Test tất cả chức năng UI
- ✅ Không bị lỗi Firebase permissions

## 3. Cấu hình Firebase Security Rules

### Bước 1: Truy cập Firebase Console
1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project StudyBuddy
3. Vào **Firestore Database** > **Rules**

### Bước 2: Cập nhật Security Rules

Thay thế rules hiện tại bằng:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép đọc/ghi tất cả collections (chỉ cho development)
    match /{document=**} {
      allow read, write: if true;
    }
    
    // Hoặc rules an toàn hơn cho production:
    /*
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /events/{eventId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    */
  }
}
```

### Bước 3: Tạo Collections

Tạo các collections sau trong Firestore:

1. **users** - Lưu thông tin người dùng
2. **tasks** - Lưu bài tập
3. **events** - Lưu sự kiện/lịch
4. **study_sessions** - Lưu phiên học tập
5. **achievements** - Lưu thành tích

### Bước 4: Cấu trúc dữ liệu mẫu

#### Collection: tasks
```json
{
  "id": "task1",
  "title": "Làm bài tập Toán chương 3",
  "description": "Hoàn thành các bài tập từ trang 45-50",
  "subject": "Toán",
  "deadline": "2024-01-15T10:00:00Z",
  "isCompleted": false,
  "priority": 2,
  "createdAt": "2024-01-10T08:00:00Z",
  "userId": "user123"
}
```

#### Collection: events
```json
{
  "id": "event1",
  "title": "Học Toán",
  "description": "Ôn tập chương 3",
  "startTime": "2024-01-15T14:00:00Z",
  "endTime": "2024-01-15T16:00:00Z",
  "type": "study",
  "subject": "Toán",
  "location": "Thư viện",
  "isAllDay": false,
  "color": "#FF6B6B",
  "userId": "user123"
}
```

#### Collection: users
```json
{
  "id": "user123",
  "name": "Nguyễn Văn A",
  "email": "nguyenvana@example.com",
  "level": 5,
  "points": 1250,
  "totalStudyTime": 480,
  "completedTasks": 8,
  "totalTasks": 12,
  "achievements": 3,
  "createdAt": "2024-01-01T00:00:00Z",
  "lastActive": "2024-01-15T10:00:00Z"
}
```

## 4. Chuyển từ Mock Data sang Real Data

Khi Firebase đã được cấu hình đúng:

1. **Xóa mock data** trong các repository files
2. **Uncomment** các Firebase calls
3. **Comment** các mock data fallbacks

### Ví dụ trong TaskRepository:

```dart
// Thay vì:
catch (e) {
  print('Firebase error: $e, using mock data');
  return _mockTasks;
}

// Sử dụng:
catch (e) {
  throw Exception('Failed to load tasks: $e');
}
```

## 5. Authentication (Tùy chọn)

Để bảo mật hơn, có thể thêm Firebase Authentication:

1. **Bật Authentication** trong Firebase Console
2. **Thêm providers** (Email/Password, Google, etc.)
3. **Cập nhật Security Rules** để kiểm tra `request.auth`
4. **Implement login/logout** trong app

## 6. Monitoring và Analytics

1. **Bật Analytics** để theo dõi usage
2. **Bật Crashlytics** để debug crashes
3. **Bật Performance Monitoring** để optimize

## 7. Backup và Recovery

1. **Export data** định kỳ từ Firestore
2. **Backup Security Rules**
3. **Document cấu trúc dữ liệu**

## 8. Troubleshooting

### Lỗi thường gặp:

1. **Permission denied**: Kiểm tra Security Rules
2. **Collection not found**: Tạo collections trước
3. **Invalid data format**: Kiểm tra cấu trúc JSON
4. **Network issues**: Kiểm tra internet connection

### Debug:

```dart
// Thêm logging để debug
print('Firebase error: $e');
print('Attempting to access collection: tasks');
```

## 9. Production Checklist

- [ ] Security Rules được cấu hình đúng
- [ ] Collections được tạo với cấu trúc đúng
- [ ] Authentication được setup (nếu cần)
- [ ] Error handling được implement
- [ ] Analytics và monitoring được bật
- [ ] Backup strategy được setup
- [ ] Performance được optimize
- [ ] Security được audit

## 10. Liên hệ hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra Firebase Console logs
2. Xem Firebase documentation
3. Tạo issue trên GitHub repository 