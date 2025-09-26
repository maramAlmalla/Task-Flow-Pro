import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for updating an existing task
/// Encapsulates business logic and validation for task updates
/// Part of the Clean Architecture's use case layer
class UpdateTaskUseCase {
  final TaskRepository _repository;

  const UpdateTaskUseCase(this._repository);

  /// Execute the use case to update an existing task
  /// Validates the updated task data before saving
  /// Throws ValidationException if task data is invalid
  /// Throws NotFoundException if task doesn't exist
  /// Throws StorageException if storage operation fails
  Future<void> call(Task task) async {
    // Validate task data
    _validateTask(task);

    // Ensure the task exists before updating
    final existingTask = await _repository.getTaskById(task.id);
    if (existingTask == null) {
      throw NotFoundException('Task with ID ${task.id} not found');
    }

    // Update the task with current timestamp
    final updatedTask = task.copyWith(
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Toggle the completion status of a task
  /// This is a common operation that deserves its own method
  Future<void> toggleTaskCompletion(String taskId) async {
    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    final updatedTask = existingTask.copyWith(
      done: !existingTask.done,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Update only the title of a task
  Future<void> updateTaskTitle(String taskId, String newTitle) async {
    final titleError = Validators.validateTaskTitle(newTitle);
    if (titleError != null) {
      throw ValidationException(titleError);
    }

    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    final updatedTask = existingTask.copyWith(
      title: newTitle.trim(),
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Update only the description of a task
  Future<void> updateTaskDescription(String taskId, String? newDescription) async {
    if (newDescription != null) {
      final descriptionError = Validators.validateTaskDescription(newDescription);
      if (descriptionError != null) {
        throw ValidationException(descriptionError);
      }
    }

    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    final updatedTask = existingTask.copyWith(
      description: newDescription?.trim(),
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Update only the due date of a task
  Future<void> updateTaskDueDate(String taskId, DateTime? newDueDate) async {
    final dueDateError = Validators.validateDueDate(newDueDate);
    if (dueDateError != null) {
      throw ValidationException(dueDateError);
    }

    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    final updatedTask = existingTask.copyWith(
      dueDate: newDueDate,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Update only the priority of a task
  Future<void> updateTaskPriority(String taskId, int newPriority) async {
    final priorityError = Validators.validatePriority(newPriority);
    if (priorityError != null) {
      throw ValidationException(priorityError);
    }

    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('Task with ID $taskId not found');
    }

    final updatedTask = existingTask.copyWith(
      priority: newPriority,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Validate task data before updating
  void _validateTask(Task task) {
    // Validate title
    final titleError = Validators.validateTaskTitle(task.title);
    if (titleError != null) {
      throw ValidationException(titleError);
    }

    // Validate description if provided
    if (task.description != null) {
      final descriptionError = Validators.validateTaskDescription(task.description);
      if (descriptionError != null) {
        throw ValidationException(descriptionError);
      }
    }

    // Validate due date if provided
    final dueDateError = Validators.validateDueDate(task.dueDate);
    if (dueDateError != null) {
      throw ValidationException(dueDateError);
    }

    // Validate priority
    final priorityError = Validators.validatePriority(task.priority);
    if (priorityError != null) {
      throw ValidationException(priorityError);
    }

    // Validate ID is not empty
    if (task.id.trim().isEmpty) {
      throw const ValidationException('Task ID cannot be empty');
    }
  }
}