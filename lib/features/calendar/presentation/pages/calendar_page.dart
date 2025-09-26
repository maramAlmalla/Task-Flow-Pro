import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/controllers/task_list_notifier.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../../core/di/di.dart';

/// Calendar page showing tasks organized by dates
/// Implements calendar view with task filtering by date
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListNotifierProvider);
    final taskNotifier = ref.read(taskListNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('calendar'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _selectedDay = DateTime.now();
              _focusedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar<Task>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) => _getTasksForDay(day, taskState.tasks),
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // Tasks for selected day
          Expanded(
            child: _buildTasksForDay(context, _selectedDay, taskState, taskNotifier),
          ),
        ],
      ),
    );
  }

  /// Get tasks for a specific day
  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate!, day);
    }).toList();
  }

  /// Build tasks list for selected day
  Widget _buildTasksForDay(
    BuildContext context,
    DateTime selectedDay,
    TaskListState taskState,
    TaskListNotifier taskNotifier,
  ) {
    final tasksForDay = _getTasksForDay(selectedDay, taskState.tasks);
    final dateFormatter = DateFormat.yMMMd();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormatter.format(selectedDay),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                _buildDayStatistics(context, tasksForDay),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tasks list
          Expanded(
            child: tasksForDay.isEmpty
                ? _buildEmptyState(context, selectedDay)
                : ListView.builder(
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return TaskCard(
                        task: task,
                        onTap: () => _navigateToTaskDetail(context, task.id),
                        onToggle: () => taskNotifier.toggleTaskCompletion(task.id),
                        onEdit: () => _navigateToEditTask(context, task),
                        onDelete: () => _showDeleteConfirmation(context, task, taskNotifier),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build day statistics
  Widget _buildDayStatistics(BuildContext context, List<Task> tasks) {
    final completedCount = tasks.where((task) => task.done).length;
    final totalCount = tasks.length;
    final pendingCount = totalCount - completedCount;

    return Row(
      children: [
        _buildStatChip(
          context,
          pendingCount.toString(),
          'pending'.tr(),
          Colors.orange,
          Icons.radio_button_unchecked,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          completedCount.toString(),
          'done'.tr(),
          Colors.green,
          Icons.check_circle,
        ),
      ],
    );
  }

  /// Build individual statistic chip
  Widget _buildStatChip(
    BuildContext context,
    String count,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state for days with no tasks
  Widget _buildEmptyState(BuildContext context, DateTime selectedDay) {
    final isToday = isSameDay(selectedDay, DateTime.now());
    final isPast = selectedDay.isBefore(DateTime.now());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPast ? Icons.check_circle_outline : Icons.event_available,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isPast
                ? 'no_tasks_this_day'.tr()
                : isToday
                    ? 'no_tasks_today'.tr()
                    : 'no_tasks_scheduled'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isPast
                ? 'great_nothing_scheduled'.tr()
                : 'add_task_for_this_day'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  /// Navigate to edit task page (placeholder)
  void _navigateToEditTask(BuildContext context, Task task) {
    // Implementation would go here - navigate to AddEditTaskPage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('edit_task_feature_coming_soon'.tr())),
    );
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
              Navigator.of(context).pop();
              notifier.deleteTask(task.id);
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}