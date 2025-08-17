import 'package:flutter/material.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/data/models/task_model.dart';

class TaskSearchDialog extends StatefulWidget {
  final List<TaskModel> allTasks;
  final Function(List<TaskModel>) onSearchResults;

  const TaskSearchDialog({
    super.key,
    required this.allTasks,
    required this.onSearchResults,
  });

  @override
  State<TaskSearchDialog> createState() => _TaskSearchDialogState();
}

class _TaskSearchDialogState extends State<TaskSearchDialog> {
  final _searchController = TextEditingController();
  List<TaskModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchResults = widget.allTasks;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppThemes.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Search Tasks',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter search keywords...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _performSearch,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Search results
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchResults.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildSearchResults(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${_searchResults.length})',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final task = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSubjectColor(task.subject),
                    child: Text(
                      task.subject[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description != null)
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${_formatDate(task.deadline)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: _getPriorityColor(task.priority),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityText(task.priority),
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: task.isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : null,
                  onTap: () {
                    widget.onSearchResults([task]);
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = widget.allTasks;
          _isSearching = false;
        });
      } else {
        final results = widget.allTasks.where((task) {
          final searchQuery = query.toLowerCase();
          return task.title.toLowerCase().contains(searchQuery) ||
                 (task.description?.toLowerCase().contains(searchQuery) ?? false) ||
                 task.subject.toLowerCase().contains(searchQuery);
        }).toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.blue;
      case 'Literature':
        return Colors.red;
      case 'English':
        return Colors.green;
      case 'Physics':
        return Colors.purple;
      case 'Chemistry':
        return Colors.orange;
      case 'Biology':
        return Colors.teal;
      case 'History':
        return Colors.brown;
      case 'Geography':
        return Colors.indigo;
      case 'Civics':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 