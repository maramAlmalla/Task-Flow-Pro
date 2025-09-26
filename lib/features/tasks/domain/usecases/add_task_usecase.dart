import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for adding a new task
/// Encapsulates business logic and validation for task creation
/// Part of the Clean Architecture's use case layer
class AddTaskUseCase {
  final TaskRepository _repository;

  const AddTaskUseCase(this._repository);

  /// Execute the use case to add a new task
  /// Validates the task data before adding to repository
  /// Throws ValidationException if task data is invalid
  /// Throws StorageException if storage operation fails
  Future<void> call(Task task) async {
    // Validate task data
    _validateTask(task);

    // Add task to repository
    await _repository.addTask(task);
  }

  /// Validate task data before creation
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

  /// Create a new task with generated ID and current timestamp
  /// This is a convenience method for creating tasks with automatic ID generation
  Future<void> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    required int priority,
    String? listId,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _generateTaskId(),
      title: title.trim(),
      description: description?.trim(),
      dueDate: dueDate,
      priority: priority,
      done: false,
      listId: listId ?? 'default',
      createdAt: now,
    );

    await call(task);
  }

  /// Generate a unique task ID
  /// Uses timestamp and random component for uniqueness
  String _generateTaskId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'task_${timestamp}_$random';
  }
}