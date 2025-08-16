import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/data/sources/local/task_local_storage.dart';
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
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      print('🔄 TaskRepository: Bắt đầu getAllTasks()');
      print('👤 TaskRepository: User ID: $userId');
      
      // Thử lấy từ Firebase trước
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
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
      
      // Lưu vào local storage để backup
      await TaskLocalStorage.saveTasks(tasks);
      
      return tasks;
    } catch (e) {
      print('❌ TaskRepository: Lỗi khi lấy tasks từ Firebase: $e');
      print('🔄 TaskRepository: Thử lấy từ local storage...');
      
      // Nếu Firebase lỗi, lấy từ local storage
      final localTasks = await TaskLocalStorage.getTasks();
      print('📱 TaskRepository: Local storage có ${localTasks.length} tasks');
      
      return localTasks;
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
    try {
      print('🔄 TaskRepository: Bắt đầu addTask()');
      print('📚 TaskRepository: Task title: ${task.title}');
      
      // Thêm vào Firebase
      final docRef = await _firestore.collection('tasks').add(task.toJson());
      final newTask = task.copyWith(id: docRef.id);
      
      // Lưu vào local storage để backup
      await TaskLocalStorage.addTask(newTask);
      
      print('✅ TaskRepository: Đã thêm task thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ TaskRepository: Lỗi khi thêm task vào Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn lưu vào local storage
      print('🔄 TaskRepository: Lưu vào local storage để backup...');
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempTask = task.copyWith(id: tempId);
      await TaskLocalStorage.addTask(tempTask);
      
      print('📱 TaskRepository: Đã lưu task vào local storage với ID tạm: $tempId');
      return tempId;
    }
  }

  // Cập nhật bài tập
  Future<void> updateTask(String taskId, TaskModel task) async {
    try {
      print('🔄 TaskRepository: Bắt đầu updateTask()');
      print('📚 TaskRepository: Task ID: $taskId, title: ${task.title}');
      
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      
      // Cập nhật Firebase
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update(updatedTask.toJson());
      
      // Cập nhật local storage
      await TaskLocalStorage.updateTask(taskId, updatedTask);
      
      print('✅ TaskRepository: Đã cập nhật task thành công');
    } catch (e) {
      print('❌ TaskRepository: Lỗi khi cập nhật task trong Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn cập nhật local storage
      print('🔄 TaskRepository: Cập nhật local storage để backup...');
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await TaskLocalStorage.updateTask(taskId, updatedTask);
      
      print('📱 TaskRepository: Đã cập nhật task trong local storage');
    }
  }

  // Xóa bài tập
  Future<void> deleteTask(String taskId) async {
    try {
      print('🔄 TaskRepository: Bắt đầu deleteTask()');
      print('📚 TaskRepository: Task ID: $taskId');
      
      // Xóa khỏi Firebase
      await _firestore.collection('tasks').doc(taskId).delete();
      
      // Xóa khỏi local storage
      await TaskLocalStorage.deleteTask(taskId);
      
      print('✅ TaskRepository: Đã xóa task thành công');
    } catch (e) {
      print('❌ TaskRepository: Lỗi khi xóa task khỏi Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn xóa khỏi local storage
      print('🔄 TaskRepository: Xóa khỏi local storage để backup...');
      await TaskLocalStorage.deleteTask(taskId);
      
      print('📱 TaskRepository: Đã xóa task khỏi local storage');
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

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 TaskRepository: Bắt đầu sync local to Firebase...');
      
      final localTasks = await TaskLocalStorage.getTasks();
      final lastSyncTime = await TaskLocalStorage.getLastSyncTime();
      
      if (localTasks.isEmpty) {
        print('📱 TaskRepository: Không có dữ liệu local để sync');
        return;
      }

      print('📱 TaskRepository: Tìm thấy ${localTasks.length} tasks trong local storage');
      
      for (final task in localTasks) {
        try {
          // Kiểm tra xem task đã tồn tại trên Firebase chưa
          final existingDoc = await _firestore.collection('tasks').doc(task.id).get();
          
          if (!existingDoc.exists) {
            // Nếu chưa tồn tại, thêm mới
            await _firestore.collection('tasks').doc(task.id).set(task.toJson());
            print('✅ TaskRepository: Đã sync task "${task.title}" lên Firebase');
          } else {
            // Nếu đã tồn tại, kiểm tra xem có cần cập nhật không
            final firebaseTask = TaskModel.fromJson({
              'id': existingDoc.id,
              ...existingDoc.data()!,
            });
            if (task.updatedAt != null && 
                (firebaseTask.updatedAt == null || 
                 task.updatedAt!.isAfter(firebaseTask.updatedAt!))) {
              await _firestore.collection('tasks').doc(task.id).update(task.toJson());
              print('✅ TaskRepository: Đã cập nhật task "${task.title}" trên Firebase');
            }
          }
        } catch (e) {
          print('⚠️ TaskRepository: Lỗi khi sync task "${task.title}": $e');
        }
      }
      
      print('✅ TaskRepository: Hoàn thành sync local to Firebase');
    } catch (e) {
      print('❌ TaskRepository: Lỗi khi sync local to Firebase: $e');
    }
  }
}
