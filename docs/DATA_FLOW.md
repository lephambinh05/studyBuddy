# Luồng Xử Lý Data trong StudyBuddy

## 1. Tổng quan luồng data

StudyBuddy sử dụng kiến trúc **Repository Pattern** với **Riverpod State Management** để xử lý data một cách hiệu quả và có thể mở rộng.

## 2. Kiến trúc Data Layer

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  State Layer    │    │  Data Layer     │
│   (Screens)     │◄──►│   (Providers)   │◄──►│  (Repositories) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Local Cache   │    │   Firebase      │
                       │   (Mock Data)   │    │   (Real Data)   │
                       └─────────────────┘    └─────────────────┘
```

## 3. Luồng xử lý chi tiết

### 3.1. Khi người dùng mở ứng dụng

1. **App khởi động** → `main.dart` → `MainScreen`
2. **TasksScreen được load** → `TaskProvider` được khởi tạo
3. **TaskProvider gọi** → `TaskRepository.getAllTasks()`
4. **TaskRepository thử kết nối Firebase**:
   - ✅ **Thành công**: Lấy data từ Firestore
   - ❌ **Thất bại**: Sử dụng mock data (fallback)
5. **Data được trả về** → `TaskProvider` cập nhật state
6. **UI tự động rebuild** → Hiển thị danh sách tasks

### 3.2. Khi người dùng thêm bài tập mới

1. **User tap FAB** → Mở dialog thêm task
2. **User nhập thông tin** → Tạo `TaskModel` object
3. **TaskProvider.addTask()** → Gọi `TaskRepository.addTask()`
4. **TaskRepository thử lưu vào Firebase**:
   - ✅ **Thành công**: Task được lưu vào Firestore
   - ❌ **Thất bại**: Task được lưu vào mock data
5. **Reload data** → `TaskProvider.loadTasks()` được gọi
6. **UI cập nhật** → Hiển thị task mới trong danh sách

### 3.3. Khi người dùng toggle completion

1. **User tap checkbox** → `TaskProvider.toggleTaskCompletion()`
2. **TaskRepository.toggleTaskCompletion()** → Cập nhật trạng thái
3. **Firebase được cập nhật** hoặc **Mock data được cập nhật**
4. **Reload data** → UI hiển thị trạng thái mới
5. **Statistics được tính toán lại** → Hiển thị thống kê mới

### 3.4. Khi người dùng filter/search

1. **User chọn filter** → `TasksScreen` cập nhật state
2. **Filter logic được áp dụng** → `_getFilteredTasks()`
3. **Filtered data được hiển thị** → Không cần gọi API mới
4. **UI rebuild** → Chỉ hiển thị tasks phù hợp

## 4. Các thành phần chính

### 4.1. Models (Data Classes)

```dart
TaskModel {
  id: String
  title: String
  description: String?
  subject: String
  deadline: DateTime
  isCompleted: bool
  priority: int
  createdAt: DateTime
  completedAt: DateTime?
}
```

**Chức năng**: Định nghĩa cấu trúc data, chuyển đổi JSON ↔ Object

### 4.2. Repositories (Data Access Layer)

```dart
TaskRepository {
  getAllTasks() → List<TaskModel>
  addTask(TaskModel) → String (ID)
  updateTask(String, TaskModel) → void
  deleteTask(String) → void
  toggleTaskCompletion(String, bool) → void
  getTaskStatistics() → Map<String, dynamic>
}
```

**Chức năng**: 
- Giao tiếp với Firebase
- Xử lý lỗi và fallback
- Cache data locally
- Transform data format

### 4.3. Providers (State Management)

```dart
TaskProvider {
  state: TaskState {
    tasks: List<TaskModel>
    isLoading: bool
    error: String?
    statistics: Map<String, dynamic>
  }
  
  loadTasks() → void
  addTask(TaskModel) → void
  updateTask(String, TaskModel) → void
  deleteTask(String) → void
  toggleTaskCompletion(String, bool) → void
}
```

**Chức năng**:
- Quản lý state của ứng dụng
- Notify UI khi data thay đổi
- Handle loading states
- Error handling

### 4.4. UI Components (Presentation Layer)

```dart
TasksScreen {
  build() → Widget
  _buildTasksList() → Widget
  _buildFilters() → Widget
  _showAddTaskDialog() → void
  _toggleTaskCompletion() → void
}
```

**Chức năng**:
- Hiển thị data cho user
- Handle user interactions
- Navigate between screens
- Show loading/error states

## 5. Error Handling Strategy

### 5.1. Firebase Connection Errors

```dart
try {
  // Thử kết nối Firebase
  final data = await firebase.getData();
  return data;
} catch (e) {
  // Fallback to mock data
  print('Firebase error: $e, using mock data');
  return mockData;
}
```

### 5.2. UI Error States

```dart
if (taskState.isLoading) {
  return LoadingWidget();
} else if (taskState.error != null) {
  return ErrorWidget(taskState.error!);
} else {
  return TaskListWidget(taskState.tasks);
}
```

### 5.3. User Feedback

- **Loading**: Spinner + "Đang tải..."
- **Error**: Icon + Error message + Retry button
- **Empty**: Icon + "Không có dữ liệu" + Add button
- **Success**: Toast notification

## 6. Performance Optimizations

### 6.1. Caching Strategy

- **Memory Cache**: Data được lưu trong Provider state
- **Offline Support**: Mock data khi không có internet
- **Lazy Loading**: Load data khi cần thiết

### 6.2. UI Optimizations

- **Shimmer Loading**: Skeleton loading animation
- **Pull to Refresh**: Swipe down để reload
- **Pagination**: Load từng trang data
- **Search Debouncing**: Delay search để tránh spam API

### 6.3. Data Optimizations

- **Selective Loading**: Chỉ load data cần thiết
- **Batch Operations**: Gộp nhiều operations
- **Background Sync**: Sync data khi app không active

## 7. Security Considerations

### 7.1. Data Validation

```dart
// Validate input trước khi lưu
if (task.title.isEmpty) {
  throw Exception('Title cannot be empty');
}
if (task.deadline.isBefore(DateTime.now())) {
  throw Exception('Deadline cannot be in the past');
}
```

### 7.2. Firebase Security Rules

```javascript
// Chỉ cho phép user đã đăng nhập
match /tasks/{taskId} {
  allow read, write: if request.auth != null && 
    resource.data.userId == request.auth.uid;
}
```

### 7.3. Data Sanitization

- **Input Validation**: Kiểm tra format data
- **XSS Prevention**: Escape HTML characters
- **SQL Injection**: Sử dụng parameterized queries

## 8. Testing Strategy

### 8.1. Unit Tests

```dart
test('TaskRepository should add task successfully', () async {
  final repository = TaskRepository();
  final task = TaskModel(...);
  
  final result = await repository.addTask(task);
  
  expect(result, isNotEmpty);
});
```

### 8.2. Widget Tests

```dart
testWidgets('TasksScreen should display tasks', (tester) async {
  await tester.pumpWidget(TasksScreen());
  
  expect(find.text('Bài Tập'), findsOneWidget);
  expect(find.byType(TaskCard), findsWidgets);
});
```

### 8.3. Integration Tests

```dart
test('Complete user flow: add task -> toggle -> delete', () async {
  // Test toàn bộ flow của user
});
```

## 9. Monitoring và Analytics

### 9.1. Performance Monitoring

- **Load Time**: Thời gian load data
- **Error Rate**: Tỷ lệ lỗi
- **User Actions**: Các action user thực hiện

### 9.2. Business Metrics

- **Task Completion Rate**: Tỷ lệ hoàn thành bài tập
- **Study Time**: Thời gian học tập
- **User Engagement**: Mức độ tương tác

## 10. Future Enhancements

### 10.1. Offline-First Architecture

- **Local Database**: SQLite cho offline storage
- **Sync Strategy**: Sync khi có internet
- **Conflict Resolution**: Xử lý conflict data

### 10.2. Real-time Updates

- **WebSocket**: Real-time notifications
- **Push Notifications**: Remind deadlines
- **Live Collaboration**: Share tasks với bạn

### 10.3. AI Features

- **Smart Recommendations**: Gợi ý bài tập
- **Predictive Analytics**: Dự đoán performance
- **Personalized Learning**: Học tập cá nhân hóa

## 11. Troubleshooting Guide

### 11.1. Common Issues

1. **Data không load**: Kiểm tra Firebase connection
2. **UI không update**: Kiểm tra Provider state
3. **Performance chậm**: Kiểm tra cache strategy
4. **Memory leaks**: Kiểm tra dispose methods

### 11.2. Debug Tools

- **Flutter Inspector**: Debug UI
- **Firebase Console**: Monitor data
- **DevTools**: Profile performance
- **Logs**: Track errors

## 12. Best Practices

### 12.1. Code Organization

- **Separation of Concerns**: Tách biệt logic
- **Single Responsibility**: Mỗi class một nhiệm vụ
- **Dependency Injection**: Inject dependencies
- **Error Boundaries**: Handle errors gracefully

### 12.2. Data Management

- **Immutable State**: Không thay đổi state trực tiếp
- **Predictable Updates**: State changes có thể dự đoán
- **Normalized Data**: Cấu trúc data chuẩn
- **Optimistic Updates**: Update UI trước khi confirm

### 12.3. User Experience

- **Loading States**: Luôn có loading indicator
- **Error Recovery**: Cho phép retry khi lỗi
- **Empty States**: Hiển thị khi không có data
- **Progressive Enhancement**: Graceful degradation 