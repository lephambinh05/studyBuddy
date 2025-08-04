import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/repositories/subject_repository.dart';
import 'package:studybuddy/data/models/subject.dart';

class SubjectState {
  final List<SubjectModel> subjects;
  final bool isLoading;
  final String? errorMessage;

  SubjectState({
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SubjectState copyWith({
    List<SubjectModel>? subjects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubjectState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SubjectNotifier extends StateNotifier<SubjectState> {
  final SubjectRepository _repository;

  SubjectNotifier(this._repository) : super(SubjectState());

  Future<void> loadSubjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      print('🔄 SubjectNotifier: Bắt đầu load subjects...');
      final subjects = await _repository.getAllSubjects();
      
      print('✅ SubjectNotifier: Load subjects thành công: ${subjects.length} subjects');
      state = state.copyWith(
        subjects: subjects,
        isLoading: false,
      );
    } catch (e) {
      print('❌ SubjectNotifier: Lỗi khi load subjects: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách môn học: $e',
      );
    }
  }

  Future<void> addSubject(SubjectModel subject) async {
    try {
      print('🔄 SubjectNotifier: Bắt đầu add subject...');
      final subjectId = await _repository.addSubject(subject);
      
      final newSubject = subject.copyWith(id: subjectId);
      final updatedSubjects = [newSubject, ...state.subjects];
      
      print('✅ SubjectNotifier: Đã thêm subject thành công: ${subject.name}');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Lỗi khi thêm subject: $e');
      state = state.copyWith(
        errorMessage: 'Không thể thêm môn học: $e',
      );
    }
  }

  Future<void> updateSubject(String subjectId, SubjectModel subject) async {
    try {
      print('🔄 SubjectNotifier: Bắt đầu update subject...');
      await _repository.updateSubject(subjectId, subject);
      
      final updatedSubjects = state.subjects.map((s) {
        if (s.id == subjectId) {
          return subject.copyWith(id: subjectId);
        }
        return s;
      }).toList();
      
      print('✅ SubjectNotifier: Đã cập nhật subject thành công: ${subject.name}');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Lỗi khi cập nhật subject: $e');
      state = state.copyWith(
        errorMessage: 'Không thể cập nhật môn học: $e',
      );
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      print('🔄 SubjectNotifier: Bắt đầu delete subject...');
      await _repository.deleteSubject(subjectId);
      
      final updatedSubjects = state.subjects.where((s) => s.id != subjectId).toList();
      
      print('✅ SubjectNotifier: Đã xóa subject thành công');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Lỗi khi xóa subject: $e');
      state = state.copyWith(
        errorMessage: 'Không thể xóa môn học: $e',
      );
    }
  }

  Future<void> createDefaultSubjects(String userId) async {
    try {
      print('🔄 SubjectNotifier: Bắt đầu tạo subjects mặc định...');
      await _repository.createDefaultSubjects(userId);
      
      // Reload subjects sau khi tạo mặc định
      await loadSubjects();
      
      print('✅ SubjectNotifier: Đã tạo subjects mặc định thành công');
    } catch (e) {
      print('❌ SubjectNotifier: Lỗi khi tạo subjects mặc định: $e');
      state = state.copyWith(
        errorMessage: 'Không thể tạo môn học mặc định: $e',
      );
    }
  }

  // Lấy subject theo ID
  SubjectModel? getSubjectById(String subjectId) {
    try {
      return state.subjects.firstWhere((subject) => subject.id == subjectId);
    } catch (e) {
      print('⚠️ SubjectNotifier: Không tìm thấy subject với ID: $subjectId');
      return null;
    }
  }

  // Lấy tên subject theo ID
  String getSubjectNameById(String subjectId) {
    final subject = getSubjectById(subjectId);
    return subject?.name ?? 'Không xác định';
  }

  // Lấy danh sách tên subjects
  List<String> getSubjectNames() {
    return state.subjects.map((subject) => subject.name).toList();
  }

  // Lấy danh sách subjects cho dropdown
  List<Map<String, dynamic>> getSubjectsForDropdown() {
    return state.subjects.map((subject) => {
      'id': subject.id,
      'name': subject.name,
      'color': subject.color,
    }).toList();
  }
}

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectProvider = StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
  final repository = ref.watch(subjectRepositoryProvider);
  return SubjectNotifier(repository);
}); 