import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/subject.dart';

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
      
      final querySnapshot = await _firestore
          .collection('subjects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final subjects = querySnapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();

      print('✅ SubjectRepository: Firebase trả về ${subjects.length} subjects cho user $userId');
      for (final subject in subjects) {
        print('📚 SubjectRepository: Subject "${subject.name}" (ID: ${subject.id})');
      }

      return subjects;
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi lấy subjects: $e');
      return [];
    }
  }

  // Thêm subject mới
  Future<String> addSubject(SubjectModel subject) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu addSubject()');
      print('📚 SubjectRepository: Subject name: ${subject.name}');
      
      final docRef = await _firestore.collection('subjects').add(subject.toFirestore());
      
      print('✅ SubjectRepository: Đã thêm subject thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi thêm subject: $e');
      rethrow;
    }
  }

  // Cập nhật subject
  Future<void> updateSubject(String subjectId, SubjectModel subject) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu updateSubject()');
      print('📚 SubjectRepository: Subject ID: $subjectId, name: ${subject.name}');
      
      await _firestore
          .collection('subjects')
          .doc(subjectId)
          .update(subject.copyWith(updatedAt: DateTime.now()).toFirestore());
      
      print('✅ SubjectRepository: Đã cập nhật subject thành công');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi cập nhật subject: $e');
      rethrow;
    }
  }

  // Xóa subject
  Future<void> deleteSubject(String subjectId) async {
    try {
      print('🔄 SubjectRepository: Bắt đầu deleteSubject()');
      print('📚 SubjectRepository: Subject ID: $subjectId');
      
      await _firestore.collection('subjects').doc(subjectId).delete();
      
      print('✅ SubjectRepository: Đã xóa subject thành công');
    } catch (e) {
      print('❌ SubjectRepository: Lỗi khi xóa subject: $e');
      rethrow;
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
} 