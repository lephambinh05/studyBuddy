# Sửa lỗi Authentication - Không sử dụng Mock Data khi đăng nhập sai

## 🚨 **Vấn đề đã phát hiện:**

Khi đăng nhập sai mật khẩu, app vẫn hiển thị mock data thay vì báo lỗi đăng nhập. Điều này gây nhầm lẫn cho người dùng.

**Vấn đề mới:** App vẫn chuyển trang ngay cả khi đăng nhập sai.

**Vấn đề mới nhất:** Error message "login failed" vẫn hiển thị khi chuyển đến màn hình đăng ký.

## ✅ **Giải pháp đã áp dụng:**

### **1. Sửa TaskRepository - Xóa hoàn toàn mock data**

**File:** `lib/data/repositories/task_repository.dart`

**Thay đổi:**
```dart
// ĐÃ XÓA: Mock data hoàn toàn
// List<TaskModel> _mockTasks = [...];

// Trước: Sử dụng mock data khi không có user
if (userId == null) {
  print('⚠️ TaskRepository: Không có user đăng nhập, tính toán từ mock data');
  return _calculateStatistics(_mockTasks);
}

// Sau: Trả về dữ liệu rỗng khi không có user
if (userId == null) {
  print('⚠️ TaskRepository: Không có user đăng nhập, trả về thống kê rỗng');
  return _calculateStatistics([]);
}
```

**Các hàm đã sửa:**
- ✅ **Xóa hoàn toàn** `_mockTasks` array
- `getAllTasks()` - Trả về `[]` thay vì mock data
- `getTasksByFilter()` - Trả về `[]` thay vì mock data  
- `getTaskById()` - Trả về `null` thay vì tìm trong mock data
- `getTaskStatistics()` - Trả về thống kê rỗng thay vì từ mock data

### **2. Sửa EventRepository - Xóa hoàn toàn mock data**

**File:** `lib/data/repositories/event_repository.dart`

**Thay đổi:**
```dart
// ĐÃ XÓA: Mock data hoàn toàn
// List<EventModel> _mockEvents = [...];

// Trước: Sử dụng mock data khi không có user
if (userId == null) return [];

// Sau: Thêm log rõ ràng và kiểm tra user
if (userId == null) {
  print('⚠️ EventRepository: Không có user đăng nhập, trả về danh sách rỗng');
  return [];
}
```

**Các hàm đã sửa:**
- ✅ **Xóa hoàn toàn** `_mockEvents` array
- `getAllEvents()` - Kiểm tra user trước khi query Firebase
- `getEventsByMonth()` - Thêm `where('userId', isEqualTo: userId)`
- `getEventsByDate()` - Thêm `where('userId', isEqualTo: userId)`
- `getEventById()` - Kiểm tra quyền sở hữu event
- `getEventsByType()` - Thêm `where('userId', isEqualTo: userId)`
- `getUpcomingEvents()` - Thêm `where('userId', isEqualTo: userId)`
- `getEventStatistics()` - Thêm `where('userId', isEqualTo: userId)`

### **3. Sửa UserNotifier - Không tự động tạo user mới**

**File:** `lib/presentation/providers/user_provider.dart`

**Thay đổi:**
```dart
// Trước: Tự động tạo user mới khi không tìm thấy
if (user != null) {
  // Load user thành công
} else {
  print('⚠️ UserNotifier: Cannot find user, creating new user...');
  await _createNewUser(); // Tạo user mới
}

// Sau: Không tạo user mới, chỉ báo lỗi
if (user != null) {
  // Load user thành công
} else {
  print('⚠️ UserNotifier: Cannot find user, user not authenticated');
  state = state.copyWith(
    user: null,
    isLoading: false,
    errorMessage: 'User not authenticated',
  );
}
```

**Đã xóa:**
- ✅ Hàm `_createNewUser()` - Không cần thiết nữa

### **4. Sửa TaskProvider - Kiểm tra authentication trước khi load**

**File:** `lib/presentation/providers/task_provider.dart`

**Thay đổi:**
```dart
// Thêm kiểm tra authentication
final authState = _ref.read(authNotifierProvider);
if (authState.status != AuthStatus.authenticated) {
  print('⚠️ TaskProvider: User not authenticated, skipping task load');
  state = state.copyWith(
    tasks: [],
    statistics: {
      'totalTasks': 0,
      'completedTasks': 0,
      'pendingTasks': 0,
      'overdueTasks': 0,
      'completionRate': 0.0,
    },
    isLoading: false,
    error: null,
  );
  return;
}
```

### **5. Sửa AuthProvider - Không chuyển trạng thái khi đăng nhập sai**

**File:** `lib/presentation/providers/auth_provider.dart`

**Thay đổi:**
```dart
// Trước: Set status thành error khi đăng nhập sai
state = state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);

// Sau: Set status thành unauthenticated khi đăng nhập sai
state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

// Thêm method để xóa error message
void clearError() {
  state = state.copyWith(errorMessage: null);
}
```

### **6. Sửa LoginScreen - Chỉ chuyển trang khi đăng nhập thành công**

**File:** `lib/presentation/screens/auth/login_screen.dart`

**Thay đổi:**
```dart
// Trước: Luôn chuyển trang sau khi gọi signInWithEmail
if (mounted) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}

// Sau: Chỉ chuyển trang khi đăng nhập thành công
final authState = ref.read(authNotifierProvider);

if (mounted && authState.status == AuthStatus.authenticated) {
  // Chỉ chuyển trang khi đăng nhập thành công
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}

// Thêm xóa error message khi chuyển đến đăng ký
TextButton(
  onPressed: () {
    // Xóa error message trước khi chuyển trang
    ref.read(authNotifierProvider.notifier).clearError();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  },
  child: Text('Register now'),
)
```

### **7. Sửa SignupScreen - Chỉ chuyển trang khi đăng ký thành công**

**File:** `lib/presentation/screens/auth/signup_screen.dart`

**Thay đổi:**
```dart
// Trước: Luôn chuyển trang sau khi gọi registerWithEmail
if (mounted) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}

// Sau: Chỉ chuyển trang khi đăng ký thành công
final authState = ref.read(authNotifierProvider);

if (mounted && authState.status == AuthStatus.authenticated) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
}

// Thêm xóa error message khi quay lại login
IconButton(
  onPressed: () {
    // Xóa error message trước khi quay lại
    ref.read(authNotifierProvider.notifier).clearError();
    Navigator.of(context).pop();
  },
  icon: Icon(Icons.arrow_back),
)
```

## 📊 **Kết quả mong đợi:**

### **Khi đăng nhập sai:**
- ✅ Hiển thị error message rõ ràng: "Email hoặc password không đúng"
- ✅ **KHÔNG hiển thị mock data** (đã xóa hoàn toàn)
- ✅ **KHÔNG chuyển trang** khi đăng nhập sai
- ✅ Danh sách tasks rỗng
- ✅ Thống kê rỗng (0 tasks)
- ✅ **KHÔNG tạo user mới** khi đăng nhập sai
- ✅ **Ở lại màn hình login** khi đăng nhập sai

### **Khi chuyển trang:**
- ✅ **Xóa error message** khi chuyển từ login sang register
- ✅ **Xóa error message** khi quay lại từ register sang login
- ✅ **Không có notification cũ** khi chuyển trang

### **Khi đăng nhập đúng:**
- ✅ Load dữ liệu thực từ Firebase
- ✅ Chuyển trang thành công đến MainScreen
- ✅ Hiển thị tasks và events của user
- ✅ Hiển thị thống kê chính xác
- ✅ Tạo user trong Firestore nếu chưa có

## 🔧 **Để test:**

1. **Đăng nhập sai:**
   - Nhập email/password không đúng
   - Kiểm tra: Không có mock data, chỉ có error message
   - Kiểm tra: **KHÔNG chuyển trang, ở lại màn hình login**

2. **Chuyển trang:**
   - Đăng nhập sai → Ấn "Register now"
   - Kiểm tra: **KHÔNG có notification "login failed"** ở màn hình đăng ký
   - Quay lại màn hình login
   - Kiểm tra: **KHÔNG có error message cũ**

3. **Đăng nhập đúng:**
   - Nhập email/password đúng
   - Kiểm tra: Load dữ liệu thực từ Firebase
   - Kiểm tra: Chuyển trang thành công đến MainScreen

4. **Đăng xuất:**
   - Kiểm tra: Danh sách tasks rỗng, không có mock data

## 📝 **Lưu ý:**

- ✅ **Đã xóa hoàn toàn mock data** khỏi tất cả repositories
- ✅ App sẽ chỉ hiển thị dữ liệu thực khi user đã đăng nhập thành công
- ✅ **Navigation logic đã được sửa** - chỉ chuyển trang khi đăng nhập thành công
- ✅ **Error message được xóa** khi chuyển trang để tránh nhầm lẫn
- ✅ Error handling rõ ràng và user-friendly
- ✅ Performance tốt hơn vì không load dữ liệu không cần thiết
- ✅ **Bảo mật tốt hơn** - không hiển thị dữ liệu khi chưa xác thực

## 🚀 **Trạng thái hiện tại:**

- ✅ **TaskRepository**: Đã xóa mock data hoàn toàn
- ✅ **EventRepository**: Đã xóa mock data hoàn toàn  
- ✅ **UserNotifier**: Không tự động tạo user mới
- ✅ **TaskProvider**: Kiểm tra authentication trước khi load
- ✅ **AuthProvider**: Không chuyển trạng thái khi đăng nhập sai + có method clearError()
- ✅ **LoginScreen**: Chỉ chuyển trang khi đăng nhập thành công + xóa error khi chuyển trang
- ✅ **SignupScreen**: Chỉ chuyển trang khi đăng ký thành công + xóa error khi quay lại
- ✅ **App**: Sẵn sàng test với dữ liệu thực và navigation đúng
