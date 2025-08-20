import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:studybuddy/data/models/task.dart';
import 'package:studybuddy/presentation/widgets/task/task_card.dart';

class TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel)? onTaskTap;
  final Function(TaskModel, TaskStatus)? onTaskStatusChanged;
  final Function(TaskModel)? onTaskDelete;
  final Function(TaskModel)? onTaskEdit;

  const TaskList({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskStatusChanged,
    this.onTaskDelete,
    this.onTaskEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                if (onTaskEdit != null)
                  SlidableAction(
                    onPressed: (_) => onTaskEdit!(task),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                if (onTaskDelete != null)
                  SlidableAction(
                    onPressed: (_) => onTaskDelete!(task),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
              ],
            ),
            child: TaskCard(
              task: task,
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
              onStatusChanged: onTaskStatusChanged != null
                  ? (newStatus) => onTaskStatusChanged!(task, newStatus)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
