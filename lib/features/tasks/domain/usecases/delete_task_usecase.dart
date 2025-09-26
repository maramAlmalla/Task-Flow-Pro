import '../repositories/task_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for deleting tasks
/// Encapsulates business logic for task deletion operations
/// Part of the Clean Architecture's use case layer
class DeleteTaskUseCase {
  final TaskRepository _repository;

  const DeleteTaskUseCase(this._repository);

  /// Execute the use case to delete a specific task
  /// Throws NotFoundException if task doesn't exist
  /// Throws StorageException if storage operation fails
  Future<void> call(String taskId) async {
    // Validate task ID
    if (taskId.trim().isEmpty) {
      throw const ValidationException('Task ID cannot be empty');
    }

    // Ensure the task exists before deleting
    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    // Delete the task
    await _repository.deleteTask(taskId);
  }

  /// Delete all completed tasks
  /// This is useful for cleaning up completed tasks in bulk
  Future<void> deleteAllCompleted() async {
    await _repository.deleteCompletedTasks();
  }

  /// Delete multiple tasks by their IDs
  /// Continues with other deletions even if some fail
  /// Returns a list of task IDs that failed to delete
  Future<List<String>> deleteMultiple(List<String> taskIds) async {
    final failedDeletions = <String>[];

    for (final taskId in taskIds) {
      try {
        await call(taskId);
      } catch (e) {
        failedDeletions.add(taskId);
        print('Failed to delete task $taskId: $e');
      }
    }

    return failedDeletions;
  }

  /// Force delete a task without checking if it exists
  /// Use with caution - only when you're certain the task exists
  /// or when you want to ensure deletion regardless of current state
  Future<void> forceDelete(String taskId) async {
    if (taskId.trim().isEmpty) {
      throw const ValidationException('Task ID cannot be empty');
    }

    try {
      await _repository.deleteTask(taskId);
    } catch (e) {
      // Log the error but don't throw - this is a force delete
      print('Force delete encountered error for task $taskId: $e');
    }
  }
}