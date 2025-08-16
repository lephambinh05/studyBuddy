import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/models/study_target.dart';
import 'package:studybuddy/data/repositories/study_target_repository.dart';
import 'package:studybuddy/data/database/sqlite_database.dart';
import 'package:studybuddy/core/services/sync_service.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';

// Provider for SQLite database
final sqliteDatabaseProvider = Provider<SQLiteDatabase>((ref) {
  return SQLiteDatabase();
});

final studyTargetRepositoryProvider = Provider<StudyTargetRepository>((ref) {
  final syncService = ref.read(syncServiceProvider.notifier);
  return StudyTargetRepository(syncService);
});

// State class for study targets
class StudyTargetState {
  final List<StudyTarget> targets;
  final List<StudyTarget> activeTargets;
  final List<StudyTarget> completedTargets;
  final List<StudyTarget> overdueTargets;
  final bool isLoading;
  final String? error;

  StudyTargetState({
    required this.targets,
    required this.activeTargets,
    required this.completedTargets,
    required this.overdueTargets,
    required this.isLoading,
    this.error,
  });

  StudyTargetState copyWith({
    List<StudyTarget>? targets,
    List<StudyTarget>? activeTargets,
    List<StudyTarget>? completedTargets,
    List<StudyTarget>? overdueTargets,
    bool? isLoading,
    String? error,
  }) {
    return StudyTargetState(
      targets: targets ?? this.targets,
      activeTargets: activeTargets ?? this.activeTargets,
      completedTargets: completedTargets ?? this.completedTargets,
      overdueTargets: overdueTargets ?? this.overdueTargets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper methods
  double get overallProgress {
    if (targets.isEmpty) return 0.0;
    final totalProgress = targets.fold<double>(0.0, (sum, target) => sum + target.progress);
    return totalProgress / targets.length;
  }

  int get totalTargets => targets.length;
  int get completedCount => completedTargets.length;
  int get activeCount => activeTargets.length;
  int get overdueCount => overdueTargets.length;
}

// Notifier for study targets
class StudyTargetNotifier extends StateNotifier<StudyTargetState> {
  final StudyTargetRepository _repository;
  final Ref _ref;

  StudyTargetNotifier(this._repository, this._ref) : super(StudyTargetState(
    targets: [],
    activeTargets: [],
    completedTargets: [],
    overdueTargets: [],
    isLoading: false,
  ));

  // Load all study targets for current user
  Future<void> loadStudyTargets() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authState = _ref.read(authNotifierProvider);
      final userId = authState.appUser?.id ?? authState.firebaseUser?.uid;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      print('🔄 StudyTargetProvider: Loading study targets for user $userId');
      
      // Load from Firebase first
      await _repository.loadFromFirebase(userId);
      
      // Then get from local storage
      final targets = await _repository.getStudyTargets(userId);
      final activeTargets = await _repository.getActiveTargets(userId);
      final completedTargets = await _repository.getCompletedTargets(userId);
      final overdueTargets = await _repository.getOverdueTargets(userId);

      print('📊 StudyTargetProvider: Loaded ${targets.length} targets from local storage');

      state = state.copyWith(
        targets: targets,
        activeTargets: activeTargets,
        completedTargets: completedTargets,
        overdueTargets: overdueTargets,
        isLoading: false,
      );
    } catch (e) {
      print('❌ StudyTargetProvider: Error loading study targets: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create new study target
  Future<void> createStudyTarget(StudyTarget target) async {
    try {
      print('🔄 StudyTargetProvider: Starting to create study target...');
      print('📊 StudyTargetProvider: Target data: ${target.title} - ${target.description}');
      
      state = state.copyWith(isLoading: true, error: null);
      
      final authState = _ref.read(authNotifierProvider);
      final userId = authState.appUser?.id ?? authState.firebaseUser?.uid;
      
      if (userId == null) {
        print('❌ StudyTargetProvider: User not authenticated');
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      print('👤 StudyTargetProvider: User ID: $userId');

      final newTarget = target.copyWith(userId: userId);
      print('📝 StudyTargetProvider: Calling repository.createStudyTarget...');
      
      final createdTarget = await _repository.createStudyTarget(newTarget);
      print('✅ StudyTargetProvider: Successfully created target with ID: ${createdTarget.id}');

      // Update state
      final updatedTargets = [createdTarget, ...state.targets];
      final updatedActiveTargets = [createdTarget, ...state.activeTargets];

      print('📊 StudyTargetProvider: Updated state - Total targets: ${updatedTargets.length}');

      state = state.copyWith(
        targets: updatedTargets,
        activeTargets: updatedActiveTargets,
        isLoading: false,
      );
      
      print('✅ StudyTargetProvider: State updated successfully');
    } catch (e) {
      print('❌ StudyTargetProvider: Error creating study target: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update study target
  Future<void> updateStudyTarget(StudyTarget target) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedTarget = await _repository.updateStudyTarget(target);

      // Update state
      final updatedTargets = state.targets.map((t) => 
        t.id == target.id ? updatedTarget : t
      ).toList();

      final updatedActiveTargets = state.activeTargets.map((t) => 
        t.id == target.id ? updatedTarget : t
      ).toList();

      final updatedCompletedTargets = state.completedTargets.map((t) => 
        t.id == target.id ? updatedTarget : t
      ).toList();

      state = state.copyWith(
        targets: updatedTargets,
        activeTargets: updatedActiveTargets,
        completedTargets: updatedCompletedTargets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Delete study target
  Future<void> deleteStudyTarget(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteStudyTarget(id);

      // Update state
      final updatedTargets = state.targets.where((t) => t.id != id).toList();
      final updatedActiveTargets = state.activeTargets.where((t) => t.id != id).toList();
      final updatedCompletedTargets = state.completedTargets.where((t) => t.id != id).toList();

      state = state.copyWith(
        targets: updatedTargets,
        activeTargets: updatedActiveTargets,
        completedTargets: updatedCompletedTargets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update current value of study target
  Future<void> updateCurrentValue(String id, double currentValue) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedTarget = await _repository.updateCurrentValue(id, currentValue);

      // Update state
      final updatedTargets = state.targets.map((t) => 
        t.id == id ? updatedTarget : t
      ).toList();

      final updatedActiveTargets = state.activeTargets.map((t) => 
        t.id == id ? updatedTarget : t
      ).toList();

      final updatedCompletedTargets = state.completedTargets.map((t) => 
        t.id == id ? updatedTarget : t
      ).toList();

      state = state.copyWith(
        targets: updatedTargets,
        activeTargets: updatedActiveTargets,
        completedTargets: updatedCompletedTargets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadStudyTargets();
  }

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 StudyTargetNotifier: Bắt đầu sync local to Firebase...');
      await _repository.syncLocalToFirebase();
      
      // Reload study targets sau khi sync
      await loadStudyTargets();
      
      print('✅ StudyTargetNotifier: Hoàn thành sync local to Firebase');
    } catch (e) {
      print('❌ StudyTargetNotifier: Lỗi khi sync local to Firebase: $e');
      state = state.copyWith(
        error: 'Không thể đồng bộ dữ liệu: $e',
      );
    }
  }
}

// Provider for StudyTargetNotifier
final studyTargetProvider = StateNotifierProvider<StudyTargetNotifier, StudyTargetState>((ref) {
  final repository = ref.watch(studyTargetRepositoryProvider);
  return StudyTargetNotifier(repository, ref);
});

 