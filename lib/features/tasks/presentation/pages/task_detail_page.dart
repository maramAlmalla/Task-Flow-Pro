import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_list_notifier.dart';
import 'add_edit_task_page.dart';
import '../../../../core/di/di.dart';

/// Task detail page showing comprehensive task information
/// Implements the View in MVVM pattern for detailed task viewing
class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskListNotifierProvider);
    final taskNotifier = ref.read(taskListNotifierProvider.notifier);
    final task = taskNotifier.getTaskById(taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: Text('task_not_found'.tr())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'task_not_found'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'task_may_have_been_deleted'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('go_back'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('task_details'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context, task),
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, action, task, taskNotifier),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_complete',
                child: Row(
                  children: [
                    Icon(
                      task.done ? Icons.radio_button_unchecked : Icons.check_circle,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.done ? 'mark_incomplete'.tr() : 'mark_complete'.tr(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('delete_task'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task completion status
            _buildStatusCard(context, task, taskNotifier),
            
            const SizedBox(height: 16),
            
            // Task title
            _buildSectionCard(
              context,
              'task_title'.tr(),
              task.title,
              Icons.title,
            ),
            
            // Task description
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                'task_description'.tr(),
                task.description!,
                Icons.description,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Task details grid
            _buildDetailsGrid(context, task),
            
            const SizedBox(height: 16),
            
            // Task metadata
            _buildMetadataCard(context, task),
          ],
        ),
      ),
    );
  }

  /// Build task status card with completion toggle
  Widget _buildStatusCard(BuildContext context, Task task, TaskListNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 32,
              color: task.done ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.done ? 'task_completed'.tr() : 'task_pending'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: task.done ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    task.done 
                        ? 'great_job_task_completed'.tr()
                        : 'click_to_mark_complete'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Switch(
              value: task.done,
              onChanged: (_) => notifier.toggleTaskCompletion(task.id),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section card for title/description
  Widget _buildSectionCard(BuildContext context, String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Build task details grid
  Widget _buildDetailsGrid(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'task_details'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'priority'.tr(),
                    task.priorityString.tr(),
                    _getPriorityIcon(task.priority),
                    _getPriorityColor(task.priority),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'status'.tr(),
                    task.done ? 'completed'.tr() : 'pending'.tr(),
                    task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    task.done ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (task.dueDate != null) ...[
              const SizedBox(height: 16),
              _buildDetailItem(
                context,
                'due_date'.tr(),
                _formatDueDate(task.dueDate!),
                Icons.schedule,
                _getDueDateColor(task),
              ),
            ],
            
            if (task.isOverdue && !task.done) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'task_overdue'.tr(),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build individual detail item
  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Build metadata card
  Widget _buildMetadataCard(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'metadata'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMetadataRow(
              context,
              'created_at'.tr(),
              DateFormat.yMMMd().add_jm().format(task.createdAt),
              Icons.add_circle,
            ),
            
            if (task.updatedAt != null) ...[
              const SizedBox(height: 8),
              _buildMetadataRow(
                context,
                'updated_at'.tr(),
                DateFormat.yMMMd().add_jm().format(task.updatedAt!),
                Icons.edit,
              ),
            ],
            
            const SizedBox(height: 8),
            _buildMetadataRow(
              context,
              'task_id'.tr(),
              task.id,
              Icons.tag,
            ),
          ],
        ),
      ),
    );
  }

  /// Build metadata row
  Widget _buildMetadataRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Get priority icon
  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 2:
        return Icons.keyboard_double_arrow_up;
      case 1:
        return Icons.keyboard_arrow_up;
      default:
        return Icons.keyboard_arrow_down;
    }
  }

  /// Get priority color
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  /// Get due date color based on urgency
  Color _getDueDateColor(Task task) {
    if (task.isOverdue && !task.done) {
      return Colors.red;
    } else if (task.isDueToday && !task.done) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  /// Format due date for display
  String _formatDueDate(DateTime dueDate) {
    return DateFormat.yMMMd().add_jm().format(dueDate);
  }

  /// Navigate to edit page
  void _navigateToEdit(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(task: task),
      ),
    );
  }

  /// Handle action menu selections
  void _handleAction(BuildContext context, String action, Task task, TaskListNotifier notifier) {
    switch (action) {
      case 'toggle_complete':
        notifier.toggleTaskCompletion(task.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, task, notifier);
        break;
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Task task, TaskListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_task'.tr()),
        content: Text('delete_task_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close detail page
              notifier.deleteTask(task.id);
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}