import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for retrieving tasks from the repository
/// Encapsulates the business logic for getting tasks with various filters
/// Part of the Clean Architecture's use case layer
class GetTasksUseCase {
  final TaskRepository _repository;

  const GetTasksUseCase(this._repository);

  /// Execute the use case to get all tasks
  Future<List<Task>> call() async {
    return await _repository.getAllTasks();
  }

  /// Get tasks filtered by completion status
  Future<List<Task>> getByStatus(bool completed) async {
    return await _repository.getTasksByStatus(completed);
  }

  /// Get tasks filtered by priority level
  Future<List<Task>> getByPriority(int priority) async {
    return await _repository.getTasksByPriority(priority);
  }

  /// Get tasks for a specific date
  Future<List<Task>> getByDate(DateTime date) async {
    return await _repository.getTasksByDate(date);
  }

  /// Get tasks within a date range
  Future<List<Task>> getByDateRange(DateTime startDate, DateTime endDate) async {
    return await _repository.getTasksByDateRange(startDate, endDate);
  }

  /// Get a specific task by ID
  Future<Task?> getById(String id) async {
    return await _repository.getTaskById(id);
  }

  /// Get task counts by status
  Future<Map<String, int>> getCounts() async {
    return await _repository.getTaskCounts();
  }

  /// Search tasks by title or description
  Future<List<Task>> search(String query) async {
    return await _repository.searchTasks(query);
  }
}