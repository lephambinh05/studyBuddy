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
      print('🔄 SubjectNotifier: Starting to load subjects...');
      final subjects = await _repository.getAllSubjects();
      
      print('✅ SubjectNotifier: Load subjects successfully: ${subjects.length} subjects');
      state = state.copyWith(
        subjects: subjects,
        isLoading: false,
      );
    } catch (e) {
      print('❌ SubjectNotifier: Error loading subjects: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Cannot load subjects: $e',
      );
    }
  }

  Future<void> addSubject(SubjectModel subject) async {
    try {
      print('🔄 SubjectNotifier: Starting to add subject...');
      final subjectId = await _repository.addSubject(subject);
      
      final newSubject = subject.copyWith(id: subjectId);
      final updatedSubjects = [newSubject, ...state.subjects];
      
      print('✅ SubjectNotifier: Added subject successfully: ${subject.name}');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Error adding subject: $e');
      state = state.copyWith(
        errorMessage: 'Cannot add subject: $e',
      );  
    }
  }

  Future<void> updateSubject(String subjectId, SubjectModel subject) async {
    try {
      print('🔄 SubjectNotifier: Starting to update subject...');
      await _repository.updateSubject(subjectId, subject);
      
      final updatedSubjects = state.subjects.map((s) {
        if (s.id == subjectId) {
          return subject.copyWith(id: subjectId);
        }
        return s;
      }).toList();
      
      print('✅ SubjectNotifier: Updated subject successfully: ${subject.name}');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Error updating subject: $e');
      state = state.copyWith(
        errorMessage: 'Cannot update subject: $e',
      );
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      print('🔄 SubjectNotifier: Starting to delete subject...');
      await _repository.deleteSubject(subjectId);
      
      final updatedSubjects = state.subjects.where((s) => s.id != subjectId).toList();
      
      print('✅ SubjectNotifier: Deleted subject successfully');
      state = state.copyWith(subjects: updatedSubjects);
    } catch (e) {
      print('❌ SubjectNotifier: Error deleting subject: $e');
      state = state.copyWith(
        errorMessage: 'Cannot delete subject: $e',
      );
    }
  }

  Future<void> createDefaultSubjects(String userId) async {
    try {
      print('🔄 SubjectNotifier: Starting to create default subjects...');
      await _repository.createDefaultSubjects(userId);
      
      // Reload subjects after creating default
      await loadSubjects();
      
      print('✅ SubjectNotifier: Created default subjects successfully');
    } catch (e) {
      print('❌ SubjectNotifier: Error creating default subjects: $e');
      state = state.copyWith(
        errorMessage: 'Cannot create default subjects: $e',
      );
    }
  }

  // Lấy subject theo ID
  SubjectModel? getSubjectById(String subjectId) {
    try {
      return state.subjects.firstWhere((subject) => subject.id == subjectId);
    } catch (e) {
      print('⚠️ SubjectNotifier: Cannot find subject with ID: $subjectId');
      return null;
    }
  }

  // Lấy tên subject theo ID
  String getSubjectNameById(String subjectId) {
    final subject = getSubjectById(subjectId);
    return subject?.name ?? 'Unknown';
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

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 SubjectNotifier: Starting sync local to Firebase...');
      await _repository.syncLocalToFirebase();
      
      // Reload subjects after sync
      await loadSubjects();
      
      print('✅ SubjectNotifier: Sync local to Firebase completed');
    } catch (e) {
      print('❌ SubjectNotifier: Error syncing local to Firebase: $e');
      state = state.copyWith(
        errorMessage: 'Cannot sync data: $e',
      );
    }
  }
}

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectProvider = StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
  final repository = ref.watch(subjectRepositoryProvider);
  return SubjectNotifier(repository);
}); 