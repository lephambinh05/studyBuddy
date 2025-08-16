import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/subject.dart';
import 'package:studybuddy/data/sources/local/subject_local_storage.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Lấy tất cả subjects của user hiện tại
  Future<List<SubjectModel>> getAllSubjects() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      print('🔄 SubjectRepository: Bắt đầu getAllSubjects()');
      print('👤 SubjectRepository: User ID: $userId');
      
      // Thử lấy từ Firebase trước
      final querySnapshot = await _firestore
          .collection('subjects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final subjects = querySnapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();

      print('✅ SubjectRepository: Firebase trả về ${subjects.length} subjects cho user $userId');
      
      // Lưu vào local storage để backup
      await SubjectLocalStorage.saveSubjects(subjects);
      
      for (final subject in subjects) {
        print('📚 SubjectRepository: Subject "${subject.name}" (ID: ${subject.id})');
      }

      return subjects;
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi lấy subjects từ Firebase: $e');
      print('🔄 SubjectRepository: Thử lấy từ local storage...');
      
      // Nếu Firebase lỗi, lấy từ local storage
      final localSubjects = await SubjectLocalStorage.getSubjects();
      print('📱 SubjectRepository: Local storage có ${localSubjects.length} subjects');
      
      return localSubjects;
    }
  }

  // Thêm subject mới
  Future<String> addSubject(SubjectModel subject) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu addSubject()');
      print('📚 SubjectRepository: Subject name: ${subject.name}');
      
      // Thêm vào Firebase
      final docRef = await _firestore.collection('subjects').add(subject.toFirestore());
      final newSubject = subject.copyWith(id: docRef.id);
      
      // Lưu vào local storage để backup
      await SubjectLocalStorage.addSubject(newSubject);
      
      print('✅ SubjectRepository: Đã thêm subject thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi thêm subject vào Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn lưu vào local storage
      print('🔄 SubjectRepository: Lưu vào local storage để backup...');
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempSubject = subject.copyWith(id: tempId);
      await SubjectLocalStorage.addSubject(tempSubject);
      
      print('📱 SubjectRepository: Đã lưu subject vào local storage với ID tạm: $tempId');
      return tempId;
    }
  }

  // Cập nhật subject
  Future<void> updateSubject(String subjectId, SubjectModel subject) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu updateSubject()');
      print('📚 SubjectRepository: Subject ID: $subjectId, name: ${subject.name}');
      
      final updatedSubject = subject.copyWith(updatedAt: DateTime.now());
      
      // Cập nhật Firebase
      await _firestore
          .collection('subjects')
          .doc(subjectId)
          .update(updatedSubject.toFirestore());
      
      // Cập nhật local storage
      await SubjectLocalStorage.updateSubject(subjectId, updatedSubject);
      
      print('✅ SubjectRepository: Đã cập nhật subject thành công');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi cập nhật subject trong Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn cập nhật local storage
      print('🔄 SubjectRepository: Cập nhật local storage để backup...');
      final updatedSubject = subject.copyWith(updatedAt: DateTime.now());
      await SubjectLocalStorage.updateSubject(subjectId, updatedSubject);
      
      print('📱 SubjectRepository: Đã cập nhật subject trong local storage');
    }
  }

  // Xóa subject
  Future<void> deleteSubject(String subjectId) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu deleteSubject()');
      print('📚 SubjectRepository: Subject ID: $subjectId');
      
      // Xóa khỏi Firebase
      await _firestore.collection('subjects').doc(subjectId).delete();
      
      // Xóa khỏi local storage
      await SubjectLocalStorage.deleteSubject(subjectId);
      
      print('✅ SubjectRepository: Đã xóa subject thành công');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi xóa subject khỏi Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn xóa khỏi local storage
      print('🔄 SubjectRepository: Xóa khỏi local storage để backup...');
      await SubjectLocalStorage.deleteSubject(subjectId);
      
      print('📱 SubjectRepository: Đã xóa subject khỏi local storage');
    }
  }

  // Lấy subject theo ID
  Future<SubjectModel?> getSubjectById(String subjectId) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu getSubjectById()');
      print('📚 SubjectRepository: Subject ID: $subjectId');
      
      final doc = await _firestore.collection('subjects').doc(subjectId).get();
      
      if (doc.exists) {
        final subject = SubjectModel.fromFirestore(doc);
        print('✅ SubjectRepository: Tìm thấy subject: ${subject.name}');
        return subject;
      } else {
        print('⚠️ SubjectRepository: Không tìm thấy subject với ID: $subjectId');
        return null;
      }
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi lấy subject: $e');
      return null;
    }
  }

  // Tạo subject mặc định cho user mới
  Future<void> createDefaultSubjects(String userId) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu createDefaultSubjects()');
      print('👤 SubjectRepository: User ID: $userId');
      
      final defaultSubjects = [
        SubjectModel(
          id: '',
          name: 'Toán',
          description: 'Môn Toán học',
          color: '#4CAF50',
          userId: userId,
          createdAt: DateTime.now(),
        ),
        SubjectModel(
          id: '',
          name: 'Văn',
          description: 'Môn Ngữ văn',
          color: '#2196F3',
          userId: userId,
          createdAt: DateTime.now(),
        ),
        SubjectModel(
          id: '',
          name: 'Anh',
          description: 'Môn Tiếng Anh',
          color: '#FF9800',
          userId: userId,
          createdAt: DateTime.now(),
        ),
        SubjectModel(
          id: '',
          name: 'Lý',
          description: 'Môn Vật lý',
          color: '#9C27B0',
          userId: userId,
          createdAt: DateTime.now(),
        ),
        SubjectModel(
          id: '',
          name: 'Hóa',
          description: 'Môn Hóa học',
          color: '#F44336',
          userId: userId,
          createdAt: DateTime.now(),
        ),
        SubjectModel(
          id: '',
          name: 'Sinh',
          description: 'Môn Sinh học',
          color: '#795548',
          userId: userId,
          createdAt: DateTime.now(),
        ),
      ];

      for (final subject in defaultSubjects) {
        await addSubject(subject);
      }

      print('✅ SubjectRepository: Đã tạo ${defaultSubjects.length} subjects mặc định');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi tạo subjects mặc định: $e');
      rethrow;
    }
  }

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 SubjectRepository: Bắt đầu sync local to Firebase...');
      
      final localSubjects = await SubjectLocalStorage.getSubjects();
      final lastSyncTime = await SubjectLocalStorage.getLastSyncTime();
      
      if (localSubjects.isEmpty) {
        print('📱 SubjectRepository: Không có dữ liệu local để sync');
        return;
      }

      print('📱 SubjectRepository: Tìm thấy ${localSubjects.length} subjects trong local storage');
      
      for (final subject in localSubjects) {
        try {
          // Kiểm tra xem subject đã tồn tại trên Firebase chưa
          final existingDoc = await _firestore.collection('subjects').doc(subject.id).get();
          
          if (!existingDoc.exists) {
            // Nếu chưa tồn tại, thêm mới
            await _firestore.collection('subjects').doc(subject.id).set(subject.toFirestore());
            print('✅ SubjectRepository: Đã sync subject "${subject.name}" lên Firebase');
          } else {
            // Nếu đã tồn tại, kiểm tra xem có cần cập nhật không
            final firebaseSubject = SubjectModel.fromFirestore(existingDoc);
            if (subject.updatedAt != null && 
                (firebaseSubject.updatedAt == null || 
                 subject.updatedAt!.isAfter(firebaseSubject.updatedAt!))) {
              await _firestore.collection('subjects').doc(subject.id).update(subject.toFirestore());
              print('✅ SubjectRepository: Đã cập nhật subject "${subject.name}" trên Firebase');
            }
          }
        } catch (e) {
          print('⚠️ SubjectRepository: Lỗi khi sync subject "${subject.name}": $e');
        }
      }
      
      print('✅ SubjectRepository: Hoàn thành sync local to Firebase');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi sync local to Firebase: $e');
    }
  }
} 