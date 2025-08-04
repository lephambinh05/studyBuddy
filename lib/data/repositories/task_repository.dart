import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/data/repositories/user_repository.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  // Lấy current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Mock data cho testing (chỉ dùng khi không có user)
  List<TaskModel> _mockTasks = [
    TaskModel(
      id: '1',
      title: 'Làm bài tập Toán chương 3',
      description: 'Hoàn thành các bài tập từ trang 45-50',
      subject: 'Toán',
      deadline: DateTime.now().add(const Duration(days: 2)),
      isCompleted: false,
      priority: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: '2',
      title: 'Ôn tập từ vựng tiếng Anh',
      description: 'Học 50 từ mới trong Unit 5',
      subject: 'Anh',
      deadline: DateTime.now().add(const Duration(days: 1)),
      isCompleted: true,
      priority: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TaskModel(
      id: '3',
      title: 'Đọc sách Văn học',
      description: 'Đọc và phân tích tác phẩm "Truyện Kiều"',
      subject: 'Văn',
      deadline: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      priority: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TaskModel(
      id: '4',
      title: 'Làm thí nghiệm Hóa học',
      description: 'Thực hành thí nghiệm về phản ứng oxi hóa khử',
      subject: 'Hóa',
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: false,
      priority: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TaskModel(
      id: '5',
      title: 'Học lý thuyết Vật lý',
      description: 'Ôn tập chương điện học và từ học',
      subject: 'Lý',
      deadline: DateTime.now().add(const Duration(days: 5)),
      isCompleted: false,
      priority: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Lấy tất cả bài tập của user hiện tại
  Future<List<TaskModel>> getAllTasks() async {
    print('🔄 TaskRepository: Bắt đầu getAllTasks()');
    
    // Kiểm tra user authentication
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, trả về mock data');
      return _mockTasks;
    }
    
    print('👤 TaskRepository: User ID: $userId');
    
    try {
      print('📡 TaskRepository: Gọi Firebase collection("tasks") với userId filter...');
      
      // Query tasks theo userId
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      
      final tasks = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TaskModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
      
      print('✅ TaskRepository: Firebase trả về ${tasks.length} tasks cho user $userId');
      return tasks;
    } catch (e) {
      print('❌ TaskRepository: Firebase error: $e, returning empty list');
      
      // Debug: Kiểm tra loại lỗi
      if (e.toString().contains('permission-denied')) {
        print('🔍 TaskRepository: Permission denied - kiểm tra Firestore rules');
        print('🔍 TaskRepository: Project ID: ${_firestore.app.options.projectId}');
        print('🔍 TaskRepository: Collection: tasks');
        print('🔍 TaskRepository: User ID: $userId');
      }
      
      return [];
    }
  }

  // Lấy bài tập theo filter
  Future<List<TaskModel>> getTasksByFilter({
    String? subject,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, trả về mock data');
      return _mockTasks;
    }
    
    try {
      Query query = _firestore.collection('tasks').where('userId', isEqualTo: userId);

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (isCompleted != null) {
        query = query.where('isCompleted', isEqualTo: isCompleted);
      }

      if (startDate != null) {
        query = query.where('deadline', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('deadline', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.orderBy('deadline').get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TaskModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      print('❌ TaskRepository: Firebase error: $e, returning empty list');
      return [];
    }
  }

  // Lấy bài tập theo ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, tìm trong mock data');
      try {
        return _mockTasks.firstWhere((task) => task.id == taskId);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Kiểm tra xem task có thuộc về user hiện tại không
        if (data['userId'] == userId) {
          return TaskModel.fromJson({
            'id': doc.id,
            ...data,
          });
        } else {
          print('⚠️ TaskRepository: Task không thuộc về user hiện tại');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ TaskRepository: Firebase error: $e');
      return null;
    }
  }

  // Thêm bài tập mới
  Future<String> addTask(TaskModel task) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, thêm vào mock data');
      final newTask = task.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
      );
      _mockTasks.insert(0, newTask);
      return newTask.id;
    }
    
    try {
      print('📝 TaskRepository: Thêm task mới cho user $userId');
      
      // Thêm userId vào task data
      final taskData = task.toJson();
      taskData['userId'] = userId;
      taskData['createdAt'] = DateTime.now().toIso8601String();
      
      final docRef = await _firestore.collection('tasks').add(taskData);
      print('✅ TaskRepository: Đã thêm task thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ TaskRepository: Firebase error khi thêm task: $e');
      rethrow;
    }
  }

  // Cập nhật bài tập
  Future<void> updateTask(String taskId, TaskModel task) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, cập nhật mock data');
      final index = _mockTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _mockTasks[index] = task;
      }
      return;
    }
    
    try {
      print('📝 TaskRepository: Cập nhật task $taskId cho user $userId');
      
      // Kiểm tra quyền sở hữu trước khi update
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        print('❌ TaskRepository: Task không tồn tại');
        return;
      }
      
      final data = doc.data();
      if (data?['userId'] != userId) {
        print('❌ TaskRepository: Task không thuộc về user hiện tại');
        return;
      }
      
      // Thêm userId vào task data
      final taskData = task.toJson();
      taskData['userId'] = userId;
      
      await _firestore.collection('tasks').doc(taskId).update(taskData);
      print('✅ TaskRepository: Đã cập nhật task thành công');
    } catch (e) {
      print('❌ TaskRepository: Firebase error khi cập nhật task: $e');
      rethrow;
    }
  }

  // Xóa bài tập
  Future<void> deleteTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, xóa khỏi mock data');
      _mockTasks.removeWhere((task) => task.id == taskId);
      return;
    }
    
    try {
      print('🗑️ TaskRepository: Xóa task $taskId cho user $userId');
      
      // Kiểm tra quyền sở hữu trước khi xóa
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        print('❌ TaskRepository: Task không tồn tại');
        return;
      }
      
      final data = doc.data();
      if (data?['userId'] != userId) {
        print('❌ TaskRepository: Task không thuộc về user hiện tại');
        return;
      }
      
      await _firestore.collection('tasks').doc(taskId).delete();
      print('✅ TaskRepository: Đã xóa task thành công');
    } catch (e) {
      print('❌ TaskRepository: Firebase error khi xóa task: $e');
      rethrow;
    }
  }

  // Toggle completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    print('🔄 TaskRepository: Bắt đầu toggleTaskCompletion()');
    print('📋 TaskRepository: TaskID: $taskId, isCompleted: $isCompleted');
    
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, không thể toggle');
      return;
    }
    
    try {
      print('📡 TaskRepository: Tìm document theo task ID: $taskId');
      
      // Tìm document theo task ID trong data thay vì document ID
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('id', isEqualTo: taskId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        print('❌ TaskRepository: Không tìm thấy document với task ID: $taskId');
        print('🔍 TaskRepository: Kiểm tra tất cả documents trong collection...');
        
        // Kiểm tra tất cả documents để debug
        final allDocs = await _firestore.collection('tasks').where('userId', isEqualTo: userId).get();
        print('📊 TaskRepository: Tổng số documents của user $userId: ${allDocs.docs.length}');
        for (final doc in allDocs.docs) {
          print('  - Document ID: ${doc.id}');
          print('  - Document data: ${doc.data()}');
        }
        
        print('❌ TaskRepository: Không tạo task mới, chỉ cập nhật task hiện có');
        return;
      }
      
      final docRef = querySnapshot.docs.first.reference;
      final docSnapshot = querySnapshot.docs.first;
      
      print('✅ TaskRepository: Tìm thấy document: ${docRef.path}');
      print('📊 TaskRepository: Document exists: ${docSnapshot.exists}');
      
      // Kiểm tra quyền sở hữu
      final data = docSnapshot.data();
      print('📊 TaskRepository: Document data hiện tại: $data');
      
      if (data?['userId'] != userId) {
        print('❌ TaskRepository: Task không thuộc về user hiện tại');
        print('📊 TaskRepository: Document userId: ${data?['userId']}');
        print('📊 TaskRepository: Current userId: $userId');
        return;
      }
      
      print('✅ TaskRepository: Document tồn tại, bắt đầu update...');
      print('📊 TaskRepository: Trạng thái cũ: ${data?['isCompleted']}');
      print('📊 TaskRepository: Trạng thái mới: $isCompleted');
      
      // Cập nhật isCompleted và completedAt
      final now = DateTime.now();
      final updateData = {
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? now.toIso8601String() : null,
        'userId': userId, // Đảm bảo userId được cập nhật
      };
      
      print('📊 TaskRepository: Update data: $updateData');
      print('📊 TaskRepository: completedAt sẽ set: ${isCompleted ? now.toIso8601String() : "null"}');
      
      await docRef.update(updateData);
      print('✅ TaskRepository: Firebase update thành công!');
      print('📊 TaskRepository: Đã cập nhật isCompleted = $isCompleted, completedAt = ${isCompleted ? now.toIso8601String() : "null"}');

      // Cập nhật consecutive days nếu task được hoàn thành
      if (isCompleted) {
        print('🔄 TaskRepository: Task hoàn thành, cập nhật consecutive days...');
        await _userRepository.updateConsecutiveDays();
      }

      // Verify update
      final updatedDoc = await docRef.get();
      final updatedData = updatedDoc.data();
      print('✅ TaskRepository: Verify - isCompleted sau update: ${updatedData?['isCompleted']}');
      print('✅ TaskRepository: Verify - completedAt sau update: ${updatedData?['completedAt']}');
      print('✅ TaskRepository: Verify - userId sau update: ${updatedData?['userId']}');
      print('✅ TaskRepository: Verify - toàn bộ data: $updatedData');
      
      // Kiểm tra xem update có thành công không
      if (updatedData?['isCompleted'] != isCompleted) {
        print('❌ TaskRepository: Update không thành công!');
        print('📊 TaskRepository: Expected isCompleted: $isCompleted');
        print('📊 TaskRepository: Actual isCompleted: ${updatedData?['isCompleted']}');
      } else {
        print('✅ TaskRepository: Update thành công! isCompleted đã được cập nhật đúng');
      }
    } catch (e) {
      print('❌ TaskRepository: Firebase error khi toggle: $e');
      rethrow;
    }
  }

  // Lấy thống kê bài tập
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ TaskRepository: Không có user đăng nhập, tính toán từ mock data');
      return _calculateStatistics(_mockTasks);
    }
    
    try {
      print('📊 TaskRepository: Bắt đầu tính toán thống kê cho user: $userId');
      final querySnapshot = await _firestore.collection('tasks').where('userId', isEqualTo: userId).get();
      
      final tasks = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Sử dụng data['id'] thay vì doc.id để đảm bảo đúng task ID
            final taskId = data['id'] ?? doc.id;
            return TaskModel.fromJson({
              'id': taskId,
              ...data,
            });
          })
          .toList();

      print('📊 TaskRepository: Tổng số tasks: ${tasks.length}');
      for (final task in tasks) {
        print('📋 TaskRepository: Task "${task.title}" (ID: ${task.id}): isCompleted = ${task.isCompleted}');
      }

      final statistics = _calculateStatistics(tasks);
      print('📊 TaskRepository: Thống kê: $statistics');
      return statistics;
    } catch (e) {
      print('❌ TaskRepository: Firebase error: $e, returning empty statistics');
      return _calculateStatistics([]);
    }
  }

  Map<String, dynamic> _calculateStatistics(List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final overdueTasks = tasks
        .where((task) => !task.isCompleted && task.deadline.isBefore(DateTime.now()))
        .length;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
    };
  }
}
