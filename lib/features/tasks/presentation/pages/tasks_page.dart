import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/task_list_notifier.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_page.dart';
import 'task_detail_page.dart';
import '../../../../core/di/di.dart';

/// Main tasks page displaying the list of tasks
/// Implements the View in MVVM pattern using ConsumerStatefulWidget
/// Provides task management functionality with filtering and search
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load tasks when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListNotifierProvider.notifier).loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListNotifierProvider);
    final taskNotifier = ref.read(taskListNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr()),
        actions: [
          // Filter menu
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) => taskNotifier.setFilter(filter),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    const SizedBox(width: 8),
                    Text('all_tasks'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.pending,
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, size: 20),
                    const SizedBox(width: 8),
                    Text('pending_tasks'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    const SizedBox(width: 8),
                    Text('completed_tasks'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.overdue,
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('overdue_tasks'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.dueToday,
                child: Row(
                  children: [
                    Icon(Icons.today, size: 20),
                    const SizedBox(width: 8),
                    Text('due_today'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.highPriority,
                child: Row(
                  children: [
                    Icon(Icons.priority_high, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('high_priority'.tr()),
                  ],
                ),
              ),
            ],
          ),
          
          // More actions menu
          PopupMenuButton<String>(
            onSelected: (action) => _handleMenuAction(action, taskNotifier),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_completed',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    const SizedBox(width: 8),
                    Text('delete_completed'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text('refresh'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_tasks'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          taskNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) => taskNotifier.setSearchQuery(query),
            ),
          ),
          
          // Task statistics
          if (taskState.tasks.isNotEmpty)
            _buildTaskStatistics(context, taskState),
          
          // Task list
          Expanded(
            child: _buildTaskList(context, taskState, taskNotifier),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build task statistics widget
  Widget _buildTaskStatistics(BuildContext context, TaskListState state) {
    final counts = state.taskCounts;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'total'.tr(), counts['total'] ?? 0, Icons.list),
          _buildStatItem(context, 'pending'.tr(), counts['pending'] ?? 0, Icons.radio_button_unchecked),
          _buildStatItem(context, 'completed'.tr(), counts['completed'] ?? 0, Icons.check_circle),
          if ((counts['overdue'] ?? 0) > 0)
            _buildStatItem(context, 'overdue'.tr(), counts['overdue'] ?? 0, Icons.warning, Colors.red),
        ],
      ),
    );
  }

  /// Build individual statistic item
  Widget _buildStatItem(BuildContext context, String label, int count, IconData icon, [Color? color]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  /// Build the main task list
  Widget _buildTaskList(BuildContext context, TaskListState state, TaskListNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.refresh(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final filteredTasks = state.filteredTasks;

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty 
                  ? 'no_tasks_found'.tr()
                  : 'no_tasks_yet'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'try_different_search'.tr()
                  : 'add_first_task'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () => _navigateToTaskDetail(context, task.id),
            onToggle: () => notifier.toggleTaskCompletion(task.id),
            onEdit: () => _navigateToEditTask(context, task),
            onDelete: () => _showDeleteConfirmation(context, task, notifier),
          );
        },
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action, TaskListNotifier notifier) {
    switch (action) {
      case 'delete_completed':
        _showDeleteCompletedConfirmation(context, notifier);
        break;
      case 'refresh':
        notifier.refresh();
        break;
    }
  }

  /// Navigate to add task page
  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskPage(),
      ),
    );
  }

  /// Navigate to edit task page
  void _navigateToEditTask(BuildContext context, task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(task: task),
      ),
    );
  }

  /// Navigate to task detail page
  void _navigateToTaskDetail(BuildContext context, String taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: taskId),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, task, TaskListNotifier notifier) {
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
              Navigator.of(context).pop();
              notifier.deleteTask(task.id);
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  /// Show delete completed tasks confirmation dialog
  void _showDeleteCompletedConfirmation(BuildContext context, TaskListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_completed_tasks'.tr()),
        content: Text('delete_completed_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.deleteCompletedTasks();
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}