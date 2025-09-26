import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository interface using local data source
/// This class bridges the domain and data layers in Clean Architecture
/// Converts between domain entities and data models
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  const TaskRepositoryImpl(this._localDataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    final taskModels = await _localDataSource.getAllTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByStatus(bool completed) async {
    final taskModels = await _localDataSource.getTasksByStatus(completed);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByPriority(int priority) async {
    final taskModels = await _localDataSource.getTasksByPriority(priority);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final taskModels = await _localDataSource.getTasksByDate(date);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    final taskModels = await _localDataSource.getTasksByDateRange(startDate, endDate);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final taskModel = await _localDataSource.getTaskById(id);
    return taskModel?.toEntity();
  }

  @override
  Future<void> addTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _localDataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> deleteCompletedTasks() async {
    await _localDataSource.deleteCompletedTasks();
  }

  @override
  Future<Map<String, int>> getTaskCounts() async {
    return await _localDataSource.getTaskCounts();
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final taskModels = await _localDataSource.searchTasks(query);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  /// Additional helper methods specific to this implementation

  /// Check if a task exists in storage
  Future<bool> taskExists(String id) async {
    return _localDataSource.taskExists(id);
  }

  /// Get all task IDs
  Future<List<String>> getAllTaskIds() async {
    return _localDataSource.getAllTaskIds();
  }

  /// Clear all tasks (use with caution - typically for testing or reset)
  Future<void> clearAllTasks() async {
    await _localDataSource.clearAllTasks();
  }

  /// Get comprehensive storage statistics
  Future<Map<String, dynamic>> getStorageStatistics() async {
    return _localDataSource.getStorageStats();
  }

  /// Get tasks that are overdue
  Future<List<Task>> getOverdueTasks() async {
    final allTasks = await getAllTasks();
    final now = DateTime.now();
    
    return allTasks.where((task) {
      if (task.dueDate == null || task.done) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  /// Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final now = DateTime.now();
    return await getTasksByDate(now);
  }

  /// Get tasks due this week
  Future<List<Task>> getTasksDueThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await getTasksByDateRange(startOfWeek, endOfWeek);
  }

  /// Get tasks by priority with filtering options
  Future<List<Task>> getTasksByPriorityAndStatus({
    required int priority,
    bool? completed,
  }) async {
    final priorityTasks = await getTasksByPriority(priority);
    
    if (completed == null) {
      return priorityTasks;
    }
    
    return priorityTasks.where((task) => task.done == completed).toList();
  }

  /// Get tasks created in a specific time period
  Future<List<Task>> getTasksByCreationDate(DateTime startDate, DateTime endDate) async {
    final allTasks = await getAllTasks();
    
    return allTasks.where((task) {
      final createdDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      return createdDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
             createdDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }
}