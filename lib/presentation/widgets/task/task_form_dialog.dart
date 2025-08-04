import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/data/models/subject.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/data/repositories/user_repository.dart';
import 'package:studybuddy/presentation/providers/user_repository_provider.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task; // null = thêm mới, not null = sửa
  final Function(TaskModel) onSave;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedSubject = ''; // Khởi tạo rỗng
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  int _selectedPriority = 2; // Medium

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Edit mode
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedSubject = widget.task!.subjectId ?? ''; // Sử dụng subjectId
      _selectedDeadline = widget.task!.deadline;
      _selectedPriority = widget.task!.priority;
    } else {
      // Add mode - tự động chọn favorite subject
      _loadFavoriteSubject();
    }
  }

  // Load favorite subject của user
  Future<void> _loadFavoriteSubject() async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final favoriteSubjectId = await userRepository.getFavoriteSubjectId();
      
      if (favoriteSubjectId != null && mounted) {
        setState(() {
          _selectedSubject = favoriteSubjectId;
        });
        print('📚 TaskFormDialog: Đã load favorite subject: $favoriteSubjectId');
      }
    } catch (e) {
      print('❌ TaskFormDialog: Lỗi khi load favorite subject: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    final theme = Theme.of(context);
    final subjectState = ref.watch(subjectProvider);
    final subjects = subjectState.subjects;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.add_task,
                    color: AppThemes.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Sửa bài tập' : 'Thêm bài tập mới',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề bài tập',
                  hintText: 'Nhập tiêu đề bài tập',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề bài tập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  hintText: 'Nhập mô tả chi tiết',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Subject dropdown
              subjects.isNotEmpty 
                ? DropdownButtonFormField<String>(
                    value: _selectedSubject.isNotEmpty && subjects.any((s) => s.id == _selectedSubject) 
                        ? _selectedSubject 
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Môn học',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.subject),
                    ),
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn môn học';
                      }
                      return null;
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.subject, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Chưa có môn học nào. Vui lòng thêm môn học trước.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 16),

              // Deadline picker
              InkWell(
                onTap: () => _selectDeadline(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn nộp',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Priority selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mức độ ưu tiên',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip(1, 'Thấp', Colors.green),
                      const SizedBox(width: 8),
                      _buildPriorityChip(2, 'Trung bình', Colors.orange),
                      const SizedBox(width: 8),
                      _buildPriorityChip(3, 'Cao', Colors.red),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDeadline = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDeadline.hour,
          _selectedDeadline.minute,
        );
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final subjectState = ref.read(subjectProvider);
      
      // Kiểm tra xem có subjects không
      if (subjectState.subjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một môn học trước khi tạo bài tập'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Lấy subject name từ subjectId
      SubjectModel? selectedSubject;
      
      try {
        selectedSubject = subjectState.subjects.firstWhere(
          (subject) => subject.id == _selectedSubject,
        );
      } catch (e) {
        // Nếu không tìm thấy, lấy subject đầu tiên
        selectedSubject = subjectState.subjects.first;
        _selectedSubject = selectedSubject.id; // Cập nhật lại selectedSubject
      }
      
      final subjectName = selectedSubject.name;
      
      // Lưu favorite subject nếu đây là task mới
      if (widget.task == null) {
        try {
          final userRepository = ref.read(userRepositoryProvider);
          await userRepository.updateFavoriteSubject(_selectedSubject);
          print('📚 TaskFormDialog: Đã lưu favorite subject: $_selectedSubject');
        } catch (e) {
          print('❌ TaskFormDialog: Lỗi khi lưu favorite subject: $e');
        }
      }
      
      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        subject: subjectName, // Tên môn học
        subjectId: _selectedSubject, // ID môn học
        deadline: _selectedDeadline,
        isCompleted: widget.task?.isCompleted ?? false,
        priority: _selectedPriority,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        completedAt: widget.task?.completedAt,
      );

      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }
} 