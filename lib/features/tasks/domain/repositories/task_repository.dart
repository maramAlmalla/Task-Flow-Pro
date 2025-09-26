import '../entities/task.dart';

/// Abstract repository interface for task operations
/// This defines the contract for task data operations in the domain layer
/// Implementation details are handled in the data layer
abstract class TaskRepository {
  /// Get all tasks from storage
  /// Returns a list of all tasks, both completed and incomplete
  Future<List<Task>> getAllTasks();

  /// Get tasks filtered by completion status
  /// [completed] - if true, returns only completed tasks; if false, returns only incomplete tasks
  Future<List<Task>> getTasksByStatus(bool completed);

  /// Get tasks filtered by priority level
  /// [priority] - 0: Low, 1: Medium, 2: High
  Future<List<Task>> getTasksByPriority(int priority);

  /// Get tasks for a specific date
  /// [date] - the date to filter tasks by (compares only date, ignores time)
  Future<List<Task>> getTasksByDate(DateTime date);

  /// Get tasks within a date range
  /// [startDate] - the start of the date range (inclusive)
  /// [endDate] - the end of the date range (inclusive)
  Future<List<Task>> getTasksByDateRange(DateTime startDate, DateTime endDate);

  /// Get a specific task by ID
  /// Returns null if no task with the given ID exists
  Future<Task?> getTaskById(String id);

  /// Add a new task to storage
  /// [task] - the task entity to add
  /// Throws StorageException if the operation fails
  Future<void> addTask(Task task);

  /// Update an existing task in storage
  /// [task] - the updated task entity
  /// Throws StorageException if the operation fails
  /// Throws NotFoundException if no task with the given ID exists
  Future<void> updateTask(Task task);

  /// Delete a task from storage
  /// [id] - the ID of the task to delete
  /// Throws StorageException if the operation fails
  /// Throws NotFoundException if no task with the given ID exists
  Future<void> deleteTask(String id);

  /// Delete all completed tasks
  /// Useful for cleaning up completed tasks in bulk
  Future<void> deleteCompletedTasks();

  /// Get the count of tasks by status
  /// Returns a map with 'total', 'completed', and 'pending' counts
  Future<Map<String, int>> getTaskCounts();

  /// Search tasks by title or description
  /// [query] - the search query string
  /// Returns tasks where title or description contains the query (case-insensitive)
  Future<List<Task>> searchTasks(String query);
}