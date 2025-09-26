import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/task.dart';

/// Task card widget for displaying individual tasks in the list
/// Includes slidable actions for edit and delete operations
/// Part of the presentation layer following MVVM pattern
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'edit'.tr(),
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'delete'.tr(),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox for completion toggle
                Checkbox(
                  value: task.done,
                  onChanged: (_) => onToggle?.call(),
                  activeColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                
                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: task.done ? TextDecoration.lineThrough : null,
                          color: task.done 
                              ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Task description if available
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            decoration: task.done ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Due date and priority row
                      if (task.dueDate != null || task.priority > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Due date
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: _getDueDateColor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(task.dueDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getDueDateColor(context),
                                  fontWeight: task.isOverdue ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                            
                            // Spacer
                            if (task.dueDate != null && task.priority > 0)
                              const SizedBox(width: 16),
                            
                            // Priority chip
                            if (task.priority > 0)
                              _buildPriorityChip(context),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Overdue indicator
                if (task.isOverdue && !task.done)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build priority chip based on task priority
  Widget _buildPriorityChip(BuildContext context) {
    Color chipColor;
    IconData priorityIcon;
    
    switch (task.priority) {
      case 2: // High
        chipColor = Colors.red;
        priorityIcon = Icons.keyboard_double_arrow_up;
        break;
      case 1: // Medium
        chipColor = Colors.orange;
        priorityIcon = Icons.keyboard_arrow_up;
        break;
      default: // Low or unknown
        chipColor = Colors.green;
        priorityIcon = Icons.keyboard_arrow_down;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priorityIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            task.priorityString.toLowerCase().tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for due date based on urgency
  Color _getDueDateColor(BuildContext context) {
    if (task.isOverdue && !task.done) {
      return Colors.red;
    } else if (task.isDueToday && !task.done) {
      return Colors.orange;
    } else {
      return Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey;
    }
  }

  /// Format due date for display
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'today'.tr();
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'tomorrow'.tr();
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '$difference ${'days_ago'.tr()}';
    } else {
      // Future date
      final difference = taskDate.difference(today).inDays;
      if (difference <= 7) {
        return 'in'.tr() + ' $difference ' + 'days'.tr();
      } else {
        return DateFormat.MMMd().format(dueDate);
      }
    }
  }
}