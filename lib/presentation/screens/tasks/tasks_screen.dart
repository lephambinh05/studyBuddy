import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/widgets/task/task_card.dart';
import 'package:studybuddy/presentation/widgets/task/task_form_dialog.dart';
import 'package:studybuddy/presentation/widgets/task/task_search_dialog.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/presentation/widgets/common/empty_state.dart';
import 'package:studybuddy/presentation/widgets/subject/subject_form_dialog.dart';
import 'package:studybuddy/data/models/subject.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedFilter = 'all';
  String _selectedSubject = 'all';
  bool _showCompleted = false; // Mặc định ẩn bài tập đã hoàn thành
  Set<String> _togglingTasks = {}; // Track tasks đang được toggle

  final List<String> _subjects = [
    'all',
    'Toán',
    'Văn',
    'Anh',
    'Lý',
    'Hóa',
    'Sinh',
    'Sử',
    'Địa',
    'GDCD',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Load data khi screen được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks();
      ref.read(subjectProvider.notifier).loadSubjects();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, taskState),
            _buildFilters(theme),
            Expanded(
              child: _buildTasksList(taskState, theme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: AppThemes.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, TaskState taskState) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppThemes.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: () => _showAddSubjectDialog(context),
                    tooltip: 'Thêm môn học',
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => _showSearchDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                context,
                'Total',
                taskState.statistics['totalTasks']?.toString() ?? '0',
                Icons.assignment,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                'Completed',
                taskState.statistics['completedTasks']?.toString() ?? '0',
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                'Overdue',
                taskState.statistics['overdueTasks']?.toString() ?? '0',
                Icons.warning,
                color: AppThemes.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Expanded(
      child: GlassCard(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final subjectState = ref.watch(subjectProvider);
    final subjects = subjectState.subjects;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Time filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all', _selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Hôm nay', 'today', _selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Tuần này', 'week', _selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip('Tháng này', 'month', _selectedFilter),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Subject filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả môn', 'all', _selectedSubject),
                const SizedBox(width: 8),
                ...subjects.map((subject) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      subject.name,
                      subject.id,
                      _selectedSubject,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Show completed toggle
          Row(
            children: [
              Text(
                'Hiển thị đã hoàn thành',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Switch(
                value: _showCompleted,
                onChanged: (value) {
                  print('🔄 User toggle show completed: $value');
                  setState(() {
                    _showCompleted = value;
                  });
                  if (value) {
                    print('📱 Hiển thị tất cả tasks (bao gồm đã hoàn thành)');
                  } else {
                    print('📱 Ẩn tasks đã hoàn thành');
                  }
                },
                activeColor: AppThemes.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Debug button đã được xóa
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        print('🔍 User chọn filter: "$label" (value: $value)');
        setState(() {
          // Phân biệt giữa time filter và subject filter
          if (value == 'all' || value == 'today' || value == 'week' || value == 'month') {
            // Time filter
            _selectedFilter = value;
            print('⏰ Cập nhật time filter: $value');
          } else {
            // Subject filter
            _selectedSubject = value;
            print('📚 Cập nhật subject filter: $value');
          }
        });
      },
      selectedColor: AppThemes.primaryColor.withOpacity(0.2),
      checkmarkColor: AppThemes.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppThemes.primaryColor : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTasksList(TaskState taskState, ThemeData theme) {
    if (taskState.isLoading) {
      return _buildLoadingState();
    }

    if (taskState.error != null) {
      return _buildErrorState(taskState.error!, theme);
    }

    final filteredTasks = _getFilteredTasks(taskState.tasks);

    if (filteredTasks.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(taskProvider.notifier).loadTasks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: TaskCard(
              title: task.title,
              description: task.description,
              subject: task.subject,
              deadline: task.deadline,
              isCompleted: task.isCompleted,
              priority: task.priority,
              isLoading: _togglingTasks.contains(task.id),
              onTap: () => _showTaskDetails(context, task),
              onToggleComplete: () => _toggleTaskCompletion(task),
              onEdit: () => _showEditTaskDialog(context, task),
              onDelete: () => _showDeleteTaskDialog(context, task),
            ),
          );
        },
      ),
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    print('🔍 Bắt đầu filter tasks. Tổng số: ${tasks.length}');
    
    // Debug: In ra trạng thái của từng task
    for (final task in tasks) {
      print('📋 Task "${task.title}" (ID: ${task.id}): isCompleted = ${task.isCompleted}');
    }
    
    // Debug: Kiểm tra duplicate tasks
    final duplicateTasks = <String, List<TaskModel>>{};
    for (final task in tasks) {
      duplicateTasks.putIfAbsent(task.title, () => []).add(task);
    }
    
    for (final entry in duplicateTasks.entries) {
      if (entry.value.length > 1) {
        print('⚠️ Duplicate tasks với title "${entry.key}":');
        for (final task in entry.value) {
          print('  - ID: ${task.id}, isCompleted: ${task.isCompleted}');
        }
      }
    }
    
    List<TaskModel> filteredTasks = tasks;

    // Filter by completion status - mặc định hiển thị tất cả
    if (!_showCompleted) {
      final beforeFilter = filteredTasks.length;
      print('🔍 Bắt đầu filter completed tasks...');
      print('🔍 _showCompleted = $_showCompleted');
      print('🔍 Tổng số tasks trước filter: $beforeFilter');
      
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
      print('✅ Filter completed tasks: $beforeFilter → ${filteredTasks.length} (ẩn ${beforeFilter - filteredTasks.length} bài tập đã hoàn thành)');
      
      // Debug: In ra danh sách task sau khi filter
      for (final task in filteredTasks) {
        print('✅ Hiển thị task: "${task.title}" (isCompleted: ${task.isCompleted})');
      }
      
      if (filteredTasks.isEmpty) {
        print('⚠️ KHÔNG CÓ TASK NÀO HIỂN THỊ! Tất cả tasks đều đã completed?');
        print('🔍 Kiểm tra lại tất cả tasks:');
        for (final task in tasks) {
          print('  - "${task.title}": isCompleted = ${task.isCompleted}');
        }
      }
    } else {
      print('✅ Hiển thị tất cả tasks (bao gồm đã hoàn thành)');
    }

    // Filter by subject
    if (_selectedSubject != 'all') {
      final beforeFilter = filteredTasks.length;
      print('🔍 Debug subject filter:');
      print('  - Selected subject ID: $_selectedSubject');
      print('  - Available tasks:');
      for (final task in filteredTasks) {
        print('    - "${task.title}": subjectId = ${task.subjectId}, subject = ${task.subject}');
      }
      
      filteredTasks = filteredTasks.where((task) => task.subjectId == _selectedSubject).toList();
      print('📚 Filter by subject ID "$_selectedSubject": $beforeFilter → ${filteredTasks.length}');
      
      if (filteredTasks.isEmpty) {
        print('⚠️ Không có task nào thuộc subject ID: $_selectedSubject');
      }
    }

    // Filter by time
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'today':
        final beforeFilter = filteredTasks.length;
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        filteredTasks = filteredTasks.where((task) =>
          task.deadline.isAfter(today) && task.deadline.isBefore(tomorrow)
        ).toList();
        print('⏰ Filter today: $beforeFilter → ${filteredTasks.length}');
        break;
      case 'week':
        final beforeFilter = filteredTasks.length;
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        filteredTasks = filteredTasks.where((task) =>
          task.deadline.isAfter(weekStart) && task.deadline.isBefore(weekEnd)
        ).toList();
        print('⏰ Filter week: $beforeFilter → ${filteredTasks.length}');
        break;
      case 'month':
        final beforeFilter = filteredTasks.length;
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        filteredTasks = filteredTasks.where((task) =>
          task.deadline.isAfter(monthStart) && task.deadline.isBefore(monthEnd)
        ).toList();
        print('⏰ Filter month: $beforeFilter → ${filteredTasks.length}');
        break;
      default:
        print('⏰ Không filter theo thời gian (all)');
    }

    // Sort tasks: overdue first, then by deadline, then by priority
    print('📊 Bắt đầu sort tasks...');
    filteredTasks.sort((a, b) {
      final now = DateTime.now();
      final aOverdue = !a.isCompleted && a.deadline.isBefore(now);
      final bOverdue = !b.isCompleted && b.deadline.isBefore(now);
      
      // Overdue tasks first
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      
      // Then by deadline (earliest first)
      final deadlineComparison = a.deadline.compareTo(b.deadline);
      if (deadlineComparison != 0) return deadlineComparison;
      
      // Then by priority (highest first)
      return a.priority.compareTo(b.priority);
    });
    print('✅ Sort tasks hoàn thành. Kết quả cuối: ${filteredTasks.length} tasks');

    return filteredTasks;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải bài tập...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(taskProvider.notifier).loadTasks();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyTasksState(
      onAddTask: () => _showAddTaskDialog(context),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (task) {
          ref.read(taskProvider.notifier).addTask(task);
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final taskState = ref.read(taskProvider);
    showDialog(
      context: context,
      builder: (context) => TaskSearchDialog(
        allTasks: taskState.tasks,
        onSearchResults: (tasks) {
          // TODO: Implement search results filtering
          print('Search results: ${tasks.length} tasks');
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Môn học', task.subject),
            _buildDetailRow('Hạn nộp', _formatDate(task.deadline)),
            _buildDetailRow('Trạng thái', task.isCompleted ? "Đã hoàn thành" : "Chưa hoàn thành"),
            _buildDetailRow('Mức ưu tiên', _getPriorityText(task.priority)),
            if (task.description != null) _buildDetailRow('Mô tả', task.description!),
            if (task.completedAt != null) _buildDetailRow('Hoàn thành lúc', _formatDateTime(task.completedAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTaskDialog(context, task);
            },
            child: const Text('Sửa'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(TaskModel task) async {
    print('🔄 Bắt đầu toggle task: "${task.title}" (ID: ${task.id})');
    print('📊 Trạng thái hiện tại: isCompleted = ${task.isCompleted}');
    
    // Check if task is overdue
    final now = DateTime.now();
    if (task.deadline.isBefore(now) && !task.isCompleted) {
      print('⚠️ Task trễ hạn: "${task.title}" - Deadline: ${task.deadline}');
      // Show overdue dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppThemes.errorColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Bài tập đã trễ hạn'),
            ],
          ),
          content: Text(
            'Bài tập "${task.title}" đã quá hạn deadline (${task.deadline.day}/${task.deadline.month}/${task.deadline.year}). '
            'Bạn không thể đánh dấu hoàn thành cho bài tập đã trễ hạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } else {
      print('✅ Task hợp lệ để toggle: "${task.title}"');
      print('🎯 Mục tiêu: isCompleted = ${!task.isCompleted}');
      
      // Track task đang được toggle
      setState(() {
        _togglingTasks.add(task.id);
      });
      print('⏳ Đã thêm task vào danh sách đang xử lý: ${_togglingTasks}');
      
      // Toggle completion normally
      try {
        print('🚀 Gọi Firebase để toggle task...');
        await ref.read(taskProvider.notifier).toggleTaskCompletion(
          task.id,
          !task.isCompleted,
        );
        print('✅ Firebase toggle thành công!');

        // Reload tasks để cập nhật UI
        print('🔄 Reload tasks để cập nhật UI...');
        
        // Delay để đảm bảo Firebase cập nhật
        await Future.delayed(const Duration(milliseconds: 500));
        print('⏳ Đã delay 500ms để Firebase cập nhật...');
        
        await ref.read(taskProvider.notifier).loadTasks();
        print('✅ Reload tasks thành công!');

        // Force rebuild UI
        if (mounted) {
          setState(() {
            print('🔄 Force rebuild UI...');
          });
        }
        
        // Hot reload để đảm bảo UI cập nhật
        print('🔄 Trigger hot reload...');
        // ref.invalidate(taskProvider); // Xóa dòng này vì nó xóa toàn bộ state
        
        // Force refresh UI
        print('🔄 Force refresh UI...');
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() {});
        }
        
        // Verify task status
        print('🔍 Verify task status sau khi toggle...');
        final updatedTasks = ref.read(taskProvider).tasks;
        final updatedTask = updatedTasks.firstWhere(
          (t) => t.id == task.id,
          orElse: () => task,
        );
        print('📊 Task "${updatedTask.title}" sau toggle: isCompleted = ${updatedTask.isCompleted}');
        
        // Debug: Kiểm tra task "111" cụ thể
        if (task.title == "111") {
          print('🔍 Debug task "111":');
          print('  - ID: ${task.id}');
          print('  - Trước toggle: isCompleted = ${task.isCompleted}');
          print('  - Sau toggle: isCompleted = ${updatedTask.isCompleted}');
          print('  - Có trong danh sách tasks: ${updatedTasks.any((t) => t.id == task.id)}');
        }

        // Auto-hide completed tasks if switch is off
        if (updatedTask.isCompleted && !_showCompleted) {
          print('🔄 Task đã hoàn thành, tự động ẩn khỏi danh sách...');
          // Force filter update
          setState(() {
            print('🔄 Force filter update để ẩn completed task...');
          });
        }

        // Hiển thị thông báo thành công
        if (context.mounted) {
          final message = task.isCompleted 
            ? 'Đã bỏ hoàn thành bài tập "${task.title}"'
            : 'Đã hoàn thành bài tập "${task.title}"' + (_showCompleted ? '' : ' (đã ẩn khỏi danh sách)');
          print('📱 Hiển thị SnackBar thành công: "$message"');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppThemes.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        print('❌ Lỗi khi toggle task: $e');
        // Hiển thị thông báo lỗi
        if (context.mounted) {
          print('📱 Hiển thị SnackBar lỗi');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể cập nhật trạng thái bài tập. Vui lòng thử lại sau.',
              ),
              backgroundColor: AppThemes.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: () {
                  print('🔄 User click "Thử lại"');
                  _toggleTaskCompletion(task);
                },
              ),
            ),
          );
        }
      } finally {
        // Remove task khỏi set đang toggle
        setState(() {
          _togglingTasks.remove(task.id);
        });
        print('✅ Đã xóa task khỏi danh sách đang xử lý: ${_togglingTasks}');
        print('🏁 Hoàn thành toggle task: "${task.title}"');
      }
    }
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    print('📝 Mở dialog chỉnh sửa task: "${task.title}" (ID: ${task.id})');
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        onSave: (updatedTask) async {
          print('💾 Bắt đầu lưu task đã chỉnh sửa: "${updatedTask.title}"');
          try {
            await ref.read(taskProvider.notifier).updateTask(task.id, updatedTask);
            print('✅ Lưu task thành công!');
            if (context.mounted) {
              Navigator.pop(context);
              print('📱 Hiển thị SnackBar thành công cho edit');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã cập nhật bài tập "${updatedTask.title}"'),
                  backgroundColor: AppThemes.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          } catch (e) {
            print('❌ Lỗi khi lưu task: $e');
            if (context.mounted) {
              print('📱 Hiển thị SnackBar lỗi cho edit');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể cập nhật bài tập. Vui lòng thử lại sau.'),
                  backgroundColor: AppThemes.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteTaskDialog(BuildContext context, TaskModel task) {
    print('🗑️ Mở dialog xóa task: "${task.title}" (ID: ${task.id})');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài tập'),
        content: Text('Bạn có chắc muốn xóa bài tập "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ User hủy xóa task: "${task.title}"');
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              print('🗑️ User xác nhận xóa task: "${task.title}"');
              try {
                await ref.read(taskProvider.notifier).deleteTask(task.id);
                print('✅ Xóa task thành công!');
                if (context.mounted) {
                  Navigator.pop(context);
                  print('📱 Hiển thị SnackBar thành công cho delete');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa bài tập "${task.title}"'),
                      backgroundColor: AppThemes.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Lỗi khi xóa task: $e');
                if (context.mounted) {
                  Navigator.pop(context);
                  print('📱 Hiển thị SnackBar lỗi cho delete');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể xóa bài tập. Vui lòng thử lại sau.'),
                      backgroundColor: AppThemes.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    print('📚 Mở dialog thêm môn học');
    showDialog(
      context: context,
      builder: (context) => SubjectFormDialog(
        onSave: (SubjectModel subject) async {
          print('📚 User thêm môn học: ${subject.name}');
          try {
            await ref.read(subjectProvider.notifier).addSubject(subject);
            print('✅ Thêm môn học thành công!');
            if (context.mounted) {
              print('📱 Hiển thị SnackBar thành công cho thêm môn học');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã thêm môn học "${subject.name}"'),
                  backgroundColor: AppThemes.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          } catch (e) {
            print('❌ Lỗi khi thêm môn học: $e');
            if (context.mounted) {
              print('📱 Hiển thị SnackBar lỗi cho thêm môn học');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể thêm môn học: $e'),
                  backgroundColor: AppThemes.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
            // Re-throw để dialog không đóng khi có lỗi
            rethrow;
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }
} 