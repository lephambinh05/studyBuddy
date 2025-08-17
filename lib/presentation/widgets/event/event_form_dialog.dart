import 'package:flutter/material.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/data/models/event_model.dart';

class EventFormDialog extends StatefulWidget {
  final EventModel? event; // null = thêm mới, not null = sửa
  final Function(EventModel) onSave;

  const EventFormDialog({
    super.key,
    this.event,
    required this.onSave,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedType = 'study';
  String? _selectedSubject;
  DateTime _selectedStartTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _selectedEndTime = DateTime.now().add(const Duration(hours: 2));
  bool _isAllDay = false;
  String _selectedColor = '#FF6B6B';

  final List<String> _types = [
    'study',
    'exam',
    'assignment',
    'other',
  ];

  final List<String> _subjects = [
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

  final List<String> _colors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#96CEB4', // Green
    '#FFEAA7', // Yellow
    '#DDA0DD', // Plum
    '#98D8C8', // Mint
    '#F7DC6F', // Gold
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Edit mode
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _locationController.text = widget.event!.location ?? '';
      _selectedType = widget.event!.type;
      _selectedSubject = widget.event!.subject;
      _selectedStartTime = widget.event!.startTime;
      _selectedEndTime = widget.event!.endTime;
      _isAllDay = widget.event!.isAllDay;
      _selectedColor = widget.event!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isEdit ? Icons.edit : Icons.event,
                      color: AppThemes.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Sửa sự kiện' : 'Thêm sự kiện mới',
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
                    labelText: 'Tiêu đề sự kiện',
                    hintText: 'Nhập tiêu đề sự kiện',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter event title';
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

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Loại sự kiện',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại sự kiện';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Subject dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Môn học (tùy chọn)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.subject),
                  ),
                  items: [
                                         const DropdownMenuItem<String>(
                       value: null,
                       child: Text('None'),
                     ),
                    ..._subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                                     labelText: 'Location (optional)',
                 hintText: 'Enter location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // All day toggle
                Row(
                  children: [
                    Checkbox(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value ?? false;
                        });
                      },
                      activeColor: AppThemes.primaryColor,
                    ),
                                         const Text('All day'),
                  ],
                ),
                const SizedBox(height: 16),

                // Time pickers
                if (!_isAllDay) ...[
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartTime(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start time',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                            ),
                            child: Text(
                              '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndTime(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End time',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                            ),
                            child: Text(
                              '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Date pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedStartTime.day}/${_selectedStartTime.month}/${_selectedStartTime.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectEndDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedEndTime.day}/${_selectedEndTime.month}/${_selectedEndTime.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      children: _colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveEvent,
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
      ),
    );
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'study':
        return 'Study';
      case 'exam':
        return 'Exam';
      case 'assignment':
        return 'Assignment';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedStartTime),
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartTime = DateTime(
          _selectedStartTime.year,
          _selectedStartTime.month,
          _selectedStartTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedEndTime),
    );
    
    if (picked != null) {
      setState(() {
        _selectedEndTime = DateTime(
          _selectedEndTime.year,
          _selectedEndTime.month,
          _selectedEndTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute,
        );
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedEndTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedEndTime.hour,
          _selectedEndTime.minute,
        );
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Validate time
      if (!_isAllDay && _selectedEndTime.isBefore(_selectedStartTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final event = EventModel(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        startTime: _selectedStartTime,
        endTime: _selectedEndTime,
        type: _selectedType,
        subject: _selectedSubject,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        isAllDay: _isAllDay,
        color: _selectedColor,
      );

      widget.onSave(event);
      Navigator.of(context).pop();
    }
  }
} 