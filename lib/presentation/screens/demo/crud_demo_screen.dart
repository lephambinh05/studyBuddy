import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/task/task_form_dialog.dart';
import 'package:studybuddy/presentation/widgets/event/event_form_dialog.dart';
import 'package:studybuddy/presentation/providers/task_provider.dart';
import 'package:studybuddy/presentation/providers/event_provider.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/data/models/event_model.dart';

class CrudDemoScreen extends ConsumerStatefulWidget {
  const CrudDemoScreen({super.key});

  @override
  ConsumerState<CrudDemoScreen> createState() => _CrudDemoScreenState();
}

class _CrudDemoScreenState extends ConsumerState<CrudDemoScreen> {
  @override
  void initState() {
    super.initState();
    // Load data khi screen được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks();
      ref.read(eventProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final eventState = ref.watch(eventProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Demo'),
        backgroundColor: AppThemes.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppThemes.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.science,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CRUD Operations Demo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test tất cả chức năng Create, Read, Update, Delete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Task Section
            _buildSection(
              context,
              '📝 Task Management',
              'Quản lý bài tập',
              Icons.assignment,
              [
                _buildDemoCard(
                  'Create Task',
                  'Thêm bài tập mới',
                  Icons.add_task,
                  Colors.green,
                  () => _showAddTaskDialog(context),
                ),
                _buildDemoCard(
                  'Read Tasks',
                  'Xem danh sách bài tập (${taskState.tasks.length})',
                  Icons.list,
                  Colors.blue,
                  () => _showTaskList(context, taskState.tasks),
                ),
                _buildDemoCard(
                  'Update Task',
                  'Sửa bài tập',
                  Icons.edit,
                  Colors.orange,
                  () => _showUpdateTaskDialog(context),
                ),
                _buildDemoCard(
                  'Delete Task',
                  'Xóa bài tập',
                  Icons.delete,
                  Colors.red,
                  () => _showDeleteTaskDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Event Section
            _buildSection(
              context,
              '📅 Event Management',
              'Quản lý sự kiện',
              Icons.event,
              [
                _buildDemoCard(
                  'Create Event',
                  'Thêm sự kiện mới',
                  Icons.add,
                  Colors.green,
                  () => _showAddEventDialog(context),
                ),
                _buildDemoCard(
                  'Read Events',
                  'Xem danh sách sự kiện (${eventState.events.length})',
                  Icons.list,
                  Colors.blue,
                  () => _showEventList(context, eventState.events),
                ),
                _buildDemoCard(
                  'Update Event',
                  'Sửa sự kiện',
                  Icons.edit,
                  Colors.orange,
                  () => _showUpdateEventDialog(context),
                ),
                _buildDemoCard(
                  'Delete Event',
                  'Xóa sự kiện',
                  Icons.delete,
                  Colors.red,
                  () => _showDeleteEventDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Section
            _buildStatisticsSection(context, taskState, eventState),
            const SizedBox(height: 24),

            // Test Actions Section
            _buildTestActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppThemes.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: children,
        ),
      ],
    );
  }

  Widget _buildDemoCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    TaskState taskState,
    EventState eventState,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: AppThemes.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '📊 Statistics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tasks',
                taskState.tasks.length.toString(),
                'Total',
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Events',
                eventState.events.length.toString(),
                'Total',
                Icons.event,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completed',
                taskState.tasks.where((t) => t.isCompleted).length.toString(),
                'Tasks',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Overdue',
                taskState.tasks
                    .where((t) => !t.isCompleted && t.deadline.isBefore(DateTime.now()))
                    .length
                    .toString(),
                'Tasks',
                Icons.warning,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_arrow, color: AppThemes.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '🧪 Test Actions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testBulkOperations(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Bulk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testDataReset(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Task CRUD Methods
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (task) {
          ref.read(taskProvider.notifier).addTask(task);
          _showSuccessSnackBar('Task added successfully!');
        },
      ),
    );
  }

  void _showUpdateTaskDialog(BuildContext context) {
    final tasks = ref.read(taskProvider).tasks;
    if (tasks.isEmpty) {
      _showErrorSnackBar('No tasks available to update');
      return;
    }

    final task = tasks.first;
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        onSave: (updatedTask) {
          ref.read(taskProvider.notifier).updateTask(task.id, updatedTask);
          _showSuccessSnackBar('Task updated successfully!');
        },
      ),
    );
  }

  void _showDeleteTaskDialog(BuildContext context) {
    final tasks = ref.read(taskProvider).tasks;
    if (tasks.isEmpty) {
      _showErrorSnackBar('No tasks available to delete');
      return;
    }

    final task = tasks.first;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
              _showSuccessSnackBar('Task deleted successfully!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTaskList(BuildContext context, List<TaskModel> tasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task List'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getSubjectColor(task.subject),
                  child: Text(
                    task.subject[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(task.title),
                subtitle: Text('Due: ${_formatDate(task.deadline)}'),
                trailing: task.isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Event CRUD Methods
  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        onSave: (event) {
          ref.read(eventProvider.notifier).addEvent(event);
          _showSuccessSnackBar('Event added successfully!');
        },
      ),
    );
  }

  void _showUpdateEventDialog(BuildContext context) {
    final events = ref.read(eventProvider).events;
    if (events.isEmpty) {
      _showErrorSnackBar('No events available to update');
      return;
    }

    final event = events.first;
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        event: event,
        onSave: (updatedEvent) {
          ref.read(eventProvider.notifier).updateEvent(event.id, updatedEvent);
          _showSuccessSnackBar('Event updated successfully!');
        },
      ),
    );
  }

  void _showDeleteEventDialog(BuildContext context) {
    final events = ref.read(eventProvider).events;
    if (events.isEmpty) {
      _showErrorSnackBar('No events available to delete');
      return;
    }

    final event = events.first;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(eventProvider.notifier).deleteEvent(event.id);
              Navigator.pop(context);
              _showSuccessSnackBar('Event deleted successfully!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEventList(BuildContext context, List<EventModel> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event List'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(int.parse(event.color.replaceAll('#', '0xFF'))),
                  child: Text(
                    event.type[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(event.title),
                subtitle: Text('${_formatDate(event.startTime)} - ${_formatDate(event.endTime)}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Test Methods
  void _testBulkOperations(BuildContext context) {
    // Add multiple tasks
    for (int i = 1; i <= 3; i++) {
      final task = TaskModel(
        id: 'bulk_$i',
        title: 'Bulk Task $i',
        description: 'This is a bulk created task',
        subject: 'Toán',
        deadline: DateTime.now().add(Duration(days: i)),
        isCompleted: false,
        priority: 2,
        createdAt: DateTime.now(),
      );
      ref.read(taskProvider.notifier).addTask(task);
    }

    // Add multiple events
    for (int i = 1; i <= 2; i++) {
      final event = EventModel(
        id: 'bulk_event_$i',
        title: 'Bulk Event $i',
        description: 'This is a bulk created event',
        startTime: DateTime.now().add(Duration(hours: i * 2)),
        endTime: DateTime.now().add(Duration(hours: i * 2 + 1)),
        type: 'study',
        subject: 'Toán',
        isAllDay: false,
        color: '#FF6B6B',
      );
      ref.read(eventProvider.notifier).addEvent(event);
    }

    _showSuccessSnackBar('Bulk operations completed!');
  }

  void _testDataReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text('This will clear all tasks and events. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all data
              ref.read(taskProvider.notifier).clearAllTasks();
              ref.read(eventProvider.notifier).clearAllEvents();
              Navigator.pop(context);
              _showSuccessSnackBar('Data reset completed!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Toán':
        return Colors.blue;
      case 'Văn':
        return Colors.red;
      case 'Anh':
        return Colors.green;
      case 'Lý':
        return Colors.purple;
      case 'Hóa':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 