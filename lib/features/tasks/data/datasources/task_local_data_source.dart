import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../../../core/errors/exceptions.dart';

/// Local data source for task operations using Hive storage
/// This class handles direct interaction with Hive database
/// Part of the data layer in Clean Architecture
class TaskLocalDataSource {
  final Box<TaskModel> _tasksBox;

  const TaskLocalDataSource(this._tasksBox);

  /// Get all tasks from local storage
  Future<List<TaskModel>> getAllTasks() async {
    try {
      return _tasksBox.values.toList();
    } catch (e) {
      throw StorageException('Failed to get all tasks: $e');
    }
  }

  /// Get tasks filtered by completion status
  Future<List<TaskModel>> getTasksByStatus(bool completed) async {
    try {
      return _tasksBox.values.where((task) => task.done == completed).toList();
    } catch (e) {
      throw StorageException('Failed to get tasks by status: $e');
    }
  }

  /// Get tasks filtered by priority level
  Future<List<TaskModel>> getTasksByPriority(int priority) async {
    try {
      return _tasksBox.values.where((task) => task.priority == priority).toList();
    } catch (e) {
      throw StorageException('Failed to get tasks by priority: $e');
    }
  }

  /// Get tasks for a specific date
  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);
      return _tasksBox.values.where((task) {
        if (task.dueDate == null) return false;
        final taskDate = DateTime(
          task.dueDate!.year, 
          task.dueDate!.month, 
          task.dueDate!.day
        );
        return taskDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      throw StorageException('Failed to get tasks by date: $e');
    }
  }

  /// Get tasks within a date range
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      return _tasksBox.values.where((task) {
        if (task.dueDate == null) return false;
        return task.dueDate!.isAfter(start.subtract(const Duration(seconds: 1))) && 
               task.dueDate!.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      throw StorageException('Failed to get tasks by date range: $e');
    }
  }

  /// Get a specific task by ID
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return _tasksBox.get(id);
    } catch (e) {
      throw StorageException('Failed to get task by ID: $e');
    }
  }

  /// Add a new task to local storage
  Future<void> addTask(TaskModel task) async {
    try {
      await _tasksBox.put(task.id, task);
    } catch (e) {
      throw StorageException('Failed to add task: $e');
    }
  }

  /// Update an existing task in local storage
  Future<void> updateTask(TaskModel task) async {
    try {
      if (!_tasksBox.containsKey(task.id)) {
        throw const NotFoundException('Task not found');
      }
      await _tasksBox.put(task.id, task);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw StorageException('Failed to update task: $e');
    }
  }

  /// Delete a task from local storage
  Future<void> deleteTask(String id) async {
    try {
      if (!_tasksBox.containsKey(id)) {
        throw const NotFoundException('Task not found');
      }
      await _tasksBox.delete(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw StorageException('Failed to delete task: $e');
    }
  }

  /// Delete all completed tasks
  Future<void> deleteCompletedTasks() async {
    try {
      final completedTaskIds = _tasksBox.values
          .where((task) => task.done)
          .map((task) => task.id)
          .toList();

      for (final id in completedTaskIds) {
        await _tasksBox.delete(id);
      }
    } catch (e) {
      throw StorageException('Failed to delete completed tasks: $e');
    }
  }

  /// Get the count of tasks by status
  Future<Map<String, int>> getTaskCounts() async {
    try {
      final allTasks = _tasksBox.values.toList();
      final completedCount = allTasks.where((task) => task.done).length;
      final pendingCount = allTasks.length - completedCount;

      return {
        'total': allTasks.length,
        'completed': completedCount,
        'pending': pendingCount,
      };
    } catch (e) {
      throw StorageException('Failed to get task counts: $e');
    }
  }

  /// Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final searchQuery = query.toLowerCase().trim();
      if (searchQuery.isEmpty) {
        return getAllTasks();
      }

      return _tasksBox.values.where((task) {
        final titleMatches = task.title.toLowerCase().contains(searchQuery);
        final descriptionMatches = task.description?.toLowerCase().contains(searchQuery) ?? false;
        return titleMatches || descriptionMatches;
      }).toList();
    } catch (e) {
      throw StorageException('Failed to search tasks: $e');
    }
  }

  /// Check if a task exists
  bool taskExists(String id) {
    return _tasksBox.containsKey(id);
  }

  /// Get all task IDs
  List<String> getAllTaskIds() {
    try {
      return _tasksBox.keys.cast<String>().toList();
    } catch (e) {
      throw StorageException('Failed to get task IDs: $e');
    }
  }

  /// Clear all tasks (use with caution)
  Future<void> clearAllTasks() async {
    try {
      await _tasksBox.clear();
    } catch (e) {
      throw StorageException('Failed to clear all tasks: $e');
    }
  }

  /// Get storage statistics
  Map<String, dynamic> getStorageStats() {
    try {
      final taskCount = _tasksBox.length;
      final completedCount = _tasksBox.values.where((task) => task.done).length;
      final pendingCount = taskCount - completedCount;
      
      // Calculate priority distribution
      final priorities = <int, int>{0: 0, 1: 0, 2: 0};
      for (final task in _tasksBox.values) {
        priorities[task.priority] = (priorities[task.priority] ?? 0) + 1;
      }

      return {
        'totalTasks': taskCount,
        'completedTasks': completedCount,
        'pendingTasks': pendingCount,
        'lowPriorityTasks': priorities[0] ?? 0,
        'mediumPriorityTasks': priorities[1] ?? 0,
        'highPriorityTasks': priorities[2] ?? 0,
        'storageSize': _tasksBox.length,
      };
    } catch (e) {
      throw StorageException('Failed to get storage statistics: $e');
    }
  }
}