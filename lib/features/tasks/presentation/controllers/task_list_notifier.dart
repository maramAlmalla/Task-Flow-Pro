import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../../../core/errors/exceptions.dart';

/// State class for task list management
/// Represents the current state of tasks in the presentation layer
class TaskListState {
  final bool isLoading;
  final List<Task> tasks;
  final String? error;
  final TaskFilter currentFilter;
  final String searchQuery;

  const TaskListState({
    this.isLoading = false,
    this.tasks = const [],
    this.error,
    this.currentFilter = TaskFilter.all,
    this.searchQuery = '',
  });

  TaskListState copyWith({
    bool? isLoading,
    List<Task>? tasks,
    String? error,
    TaskFilter? currentFilter,
    String? searchQuery,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get filtered tasks based on current filter
  List<Task> get filteredTasks {
    List<Task> filtered = List.from(tasks);

    // Apply search filter if query is not empty
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        final titleMatches = task.title.toLowerCase().contains(query);
        final descriptionMatches = task.description?.toLowerCase().contains(query) ?? false;
        return titleMatches || descriptionMatches;
      }).toList();
    }

    // Apply status filter
    switch (currentFilter) {
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.done).toList();
        break;
      case TaskFilter.pending:
        filtered = filtered.where((task) => !task.done).toList();
        break;
      case TaskFilter.overdue:
        filtered = filtered.where((task) => task.isOverdue).toList();
        break;
      case TaskFilter.dueToday:
        filtered = filtered.where((task) => task.isDueToday).toList();
        break;
      case TaskFilter.highPriority:
        filtered = filtered.where((task) => task.priority == 2).toList();
        break;
      case TaskFilter.all:
      default:
        // No additional filtering needed
        break;
    }

    // Sort by priority (high first) then by due date (earliest first) then by creation date
    filtered.sort((a, b) {
      // First sort by completion status (incomplete tasks first)
      if (a.done != b.done) {
        return a.done ? 1 : -1;
      }

      // Then by priority (high to low)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }

      // Then by due date (earliest first, null dates last)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1; // a has due date, b doesn't - a comes first
      } else if (b.dueDate != null) {
        return 1; // b has due date, a doesn't - b comes first
      }

      // Finally by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  /// Get task counts for different categories
  Map<String, int> get taskCounts {
    return {
      'total': tasks.length,
      'completed': tasks.where((task) => task.done).length,
      'pending': tasks.where((task) => !task.done).length,
      'overdue': tasks.where((task) => task.isOverdue).length,
      'dueToday': tasks.where((task) => task.isDueToday).length,
      'highPriority': tasks.where((task) => task.priority == 2 && !task.done).length,
    };
  }
}

/// Enum for different task filtering options
enum TaskFilter {
  all,
  completed,
  pending,
  overdue,
  dueToday,
  highPriority,
}

/// StateNotifier for managing task list state and operations
/// This is the ViewModel in the MVVM pattern, handling business logic
/// and state management for the task list presentation
class TaskListNotifier extends StateNotifier<TaskListState> {
  final GetTasksUseCase _getTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  TaskListNotifier({
    required GetTasksUseCase getTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(const TaskListState());

  /// Load all tasks from the repository
  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await _getTasksUseCase();
      state = state.copyWith(
        isLoading: false,
        tasks: tasks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Create a new task
  Future<void> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    required int priority,
    String? listId,
  }) async {
    try {
      await _addTaskUseCase.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        listId: listId,
      );

      // Reload tasks to reflect the new addition
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _updateTaskUseCase(task);
      
      // Update the task in the current state
      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Toggle the completion status of a task
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      await _updateTaskUseCase.toggleTaskCompletion(taskId);
      
      // Update the task in the current state
      final updatedTasks = state.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(
            done: !task.done,
            updatedAt: DateTime.now(),
          );
        }
        return task;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _deleteTaskUseCase(taskId);
      
      // Remove the task from the current state
      final updatedTasks = state.tasks.where((task) => task.id != taskId).toList();
      
      state = state.copyWith(
        tasks: updatedTasks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Delete all completed tasks
  Future<void> deleteCompletedTasks() async {
    try {
      await _deleteTaskUseCase.deleteAllCompleted();
      
      // Remove completed tasks from the current state
      final updatedTasks = state.tasks.where((task) => !task.done).toList();
      
      state = state.copyWith(
        tasks: updatedTasks,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Set the current filter for displaying tasks
  void setFilter(TaskFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// Set the search query for filtering tasks
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh the task list
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Get task by ID from current state
  Task? getTaskById(String id) {
    try {
      return state.tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get tasks by priority from current state
  List<Task> getTasksByPriority(int priority) {
    return state.tasks.where((task) => task.priority == priority).toList();
  }

  /// Get overdue tasks from current state
  List<Task> getOverdueTasks() {
    return state.tasks.where((task) => task.isOverdue).toList();
  }

  /// Get tasks due today from current state
  List<Task> getTasksDueToday() {
    return state.tasks.where((task) => task.isDueToday).toList();
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else if (error is NotFoundException) {
      return 'Task not found: ${error.message}';
    } else if (error is AppException) {
      return error.message;
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }
}