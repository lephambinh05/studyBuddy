import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/data/models/subject.dart';
import 'package:studybuddy/presentation/providers/subject_provider.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';

class SubjectFormDialog extends ConsumerStatefulWidget {
  final SubjectModel? subject; // null = thêm mới, not null = sửa
  final Function(SubjectModel) onSave;

  const SubjectFormDialog({
    super.key,
    this.subject,
    required this.onSave,
  });

  @override
  ConsumerState<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends ConsumerState<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedColor = '#4CAF50'; // Màu mặc định

  final List<Map<String, String>> _colors = [
    {'name': 'Green', 'value': '#4CAF50'},
    {'name': 'Blue', 'value': '#2196F3'},
    {'name': 'Orange', 'value': '#FF9800'},
    {'name': 'Purple', 'value': '#9C27B0'},
    {'name': 'Red', 'value': '#F44336'},
    {'name': 'Brown', 'value': '#795548'},
    {'name': 'Gray', 'value': '#607D8B'},
    {'name': 'Pink', 'value': '#E91E63'},
    {'name': 'Yellow', 'value': '#FFC107'},
    {'name': 'Cyan', 'value': '#00BCD4'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      // Edit mode
      _nameController.text = widget.subject!.name;
      _descriptionController.text = widget.subject!.description ?? '';
      _selectedColor = widget.subject!.color ?? '#4CAF50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;
    final theme = Theme.of(context);

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
                    isEdit ? Icons.edit : Icons.add,
                    color: AppThemes.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Subject' : 'Add New Subject',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                                  labelText: 'Subject Name',
                hintText: 'Enter subject name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.subject),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                                  labelText: 'Description (optional)',
                hintText: 'Enter detailed description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Color picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color['value'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color['value']!;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color['value']!.substring(1), radix: 16) + 0xFF000000),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
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
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isEdit ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authNotifierProvider);
      final userId = authState.firebaseUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to add subjects')),
        );
        return;
      }

      final subject = SubjectModel(
        id: widget.subject?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        color: _selectedColor,
        userId: userId,
        createdAt: widget.subject?.createdAt ?? DateTime.now(),
        updatedAt: widget.subject != null ? DateTime.now() : null,
      );

      widget.onSave(subject);
      Navigator.of(context).pop();
    }
  }
} 