import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/data/models/study_target.dart';
import 'package:studybuddy/presentation/providers/study_target_provider.dart';

class StudyTargetFormDialog extends ConsumerStatefulWidget {
  final StudyTarget? target; // null for create, not null for edit

  const StudyTargetFormDialog({super.key, this.target});

  @override
  ConsumerState<StudyTargetFormDialog> createState() => _StudyTargetFormDialogState();
}

class _StudyTargetFormDialogState extends ConsumerState<StudyTargetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  
  String _selectedTargetType = StudyTarget.TASK_COUNT;
  String _selectedUnit = StudyTarget.UNIT_TASKS;
  DateTime? _endDate;
  bool _hasEndDate = false;

  @override
  void initState() {
    super.initState();
    if (widget.target != null) {
      _titleController.text = widget.target!.title;
      _descriptionController.text = widget.target!.description;
      _targetValueController.text = widget.target!.targetValue.toString();
      _selectedTargetType = widget.target!.targetType;
      _selectedUnit = widget.target!.unit;
      _endDate = widget.target!.endDate;
      _hasEndDate = widget.target!.endDate != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  void _updateUnit() {
    setState(() {
      switch (_selectedTargetType) {
        case StudyTarget.TASK_COUNT:
          _selectedUnit = StudyTarget.UNIT_TASKS;
          break;
        case StudyTarget.STUDY_DAYS:
          _selectedUnit = StudyTarget.UNIT_DAYS;
          break;
        case StudyTarget.COMPLETION_RATE:
          _selectedUnit = StudyTarget.UNIT_PERCENT;
          break;
        case StudyTarget.CUSTOM:
          _selectedUnit = StudyTarget.UNIT_CUSTOM;
          break;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveTarget() async {
    if (!_formKey.currentState!.validate()) return;

    final targetValue = double.tryParse(_targetValueController.text) ?? 0.0;
    
    StudyTarget newTarget;
    
    switch (_selectedTargetType) {
      case StudyTarget.TASK_COUNT:
        newTarget = StudyTarget.taskCount(
          id: widget.target?.id ?? '',
          userId: '', // Will be set by provider
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetValue: targetValue,
          currentValue: widget.target?.currentValue ?? 0.0,
          startDate: widget.target?.startDate,
          endDate: _hasEndDate ? _endDate : null,
        );
        break;
      case StudyTarget.STUDY_DAYS:
        newTarget = StudyTarget.studyDays(
          id: widget.target?.id ?? '',
          userId: '', // Will be set by provider
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetValue: targetValue,
          currentValue: widget.target?.currentValue ?? 0.0,
          startDate: widget.target?.startDate,
          endDate: _hasEndDate ? _endDate : null,
        );
        break;
      case StudyTarget.COMPLETION_RATE:
        newTarget = StudyTarget.completionRate(
          id: widget.target?.id ?? '',
          userId: '', // Will be set by provider
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetValue: targetValue,
          currentValue: widget.target?.currentValue ?? 0.0,
          startDate: widget.target?.startDate,
          endDate: _hasEndDate ? _endDate : null,
        );
        break;
      default:
        newTarget = StudyTarget(
          id: widget.target?.id ?? '',
          userId: '', // Will be set by provider
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetType: _selectedTargetType,
          targetValue: targetValue,
          currentValue: widget.target?.currentValue ?? 0.0,
          unit: _selectedUnit,
          startDate: widget.target?.startDate ?? DateTime.now(),
          endDate: _hasEndDate ? _endDate : null,
          isCompleted: widget.target?.isCompleted ?? false,
          createdAt: widget.target?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        );
    }

    try {
      if (widget.target != null) {
        await ref.read(studyTargetProvider.notifier).updateStudyTarget(newTarget);
      } else {
        await ref.read(studyTargetProvider.notifier).createStudyTarget(newTarget);
      }
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.target != null ? 'Cập nhật mục tiêu thành công!' : 'Tạo mục tiêu thành công!'),
            backgroundColor: AppThemes.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.target != null ? 'Chỉnh sửa mục tiêu' : 'Tạo mục tiêu mới',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề mục tiêu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Target Type
              DropdownButtonFormField<String>(
                value: _selectedTargetType,
                decoration: const InputDecoration(
                  labelText: 'Loại mục tiêu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: StudyTarget.TASK_COUNT,
                    child: const Text('Số bài tập'),
                  ),
                  DropdownMenuItem(
                    value: StudyTarget.STUDY_DAYS,
                    child: const Text('Số ngày học'),
                  ),
                  DropdownMenuItem(
                    value: StudyTarget.COMPLETION_RATE,
                    child: const Text('Tỷ lệ hoàn thành'),
                  ),
                  DropdownMenuItem(
                    value: StudyTarget.CUSTOM,
                    child: const Text('Tùy chỉnh'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTargetType = value!;
                    _updateUnit();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Target Value
              TextFormField(
                controller: _targetValueController,
                decoration: InputDecoration(
                  labelText: 'Giá trị mục tiêu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.track_changes),
                  suffixText: _selectedUnit,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá trị mục tiêu';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Giá trị phải là số dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // End Date
              Row(
                children: [
                  Checkbox(
                    value: _hasEndDate,
                    onChanged: (value) {
                      setState(() {
                        _hasEndDate = value ?? false;
                        if (!_hasEndDate) {
                          _endDate = null;
                        }
                      });
                    },
                  ),
                  const Text('Có ngày kết thúc'),
                ],
              ),
              if (_hasEndDate) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null 
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Chọn ngày kết thúc',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveTarget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.target != null ? 'Cập nhật' : 'Tạo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 