import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/data/repositories_impl/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/presentation/controllers/task_list_notifier.dart';

/// Dependency Injection setup for the Clean Architecture application
/// This file centralizes all provider definitions following the MVVM pattern
/// with clear separation between data, domain, and presentation layers

// =============================================================================
// DATA LAYER PROVIDERS
// =============================================================================

/// Provider for the Hive tasks box
/// This box stores TaskModel objects in local storage
final tasksBoxProvider = Provider<Box<TaskModel>>((ref) {
  return Hive.box<TaskModel>('tasks_box');
});

/// Provider for the Hive settings box
/// This box stores application settings like theme, locale, etc.
final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings_box');
});

/// Provider for the task local data source
/// Handles direct interaction with Hive storage for tasks
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final tasksBox = ref.watch(tasksBoxProvider);
  return TaskLocalDataSource(tasksBox);
});

// =============================================================================
// DOMAIN LAYER PROVIDERS
// =============================================================================

/// Provider for the task repository
/// Implements the domain's TaskRepository interface
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource);
});

/// Provider for the Get Tasks use case
/// Handles retrieving tasks from the repository
final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksUseCase(repository);
});

/// Provider for the Add Task use case
/// Handles adding new tasks through the repository
final addTaskUseCaseProvider = Provider<AddTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return AddTaskUseCase(repository);
});

/// Provider for the Update Task use case
/// Handles updating existing tasks through the repository
final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTaskUseCase(repository);
});

/// Provider for the Delete Task use case
/// Handles deleting tasks through the repository
final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTaskUseCase(repository);
});

// =============================================================================
// PRESENTATION LAYER PROVIDERS
// =============================================================================

/// Provider for the task list state notifier
/// Manages the state of the tasks list in the presentation layer
final taskListNotifierProvider = 
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  final getTasksUseCase = ref.watch(getTasksUseCaseProvider);
  final addTaskUseCase = ref.watch(addTaskUseCaseProvider);
  final updateTaskUseCase = ref.watch(updateTaskUseCaseProvider);
  final deleteTaskUseCase = ref.watch(deleteTaskUseCaseProvider);
  
  return TaskListNotifier(
    getTasksUseCase: getTasksUseCase,
    addTaskUseCase: addTaskUseCase,
    updateTaskUseCase: updateTaskUseCase,
    deleteTaskUseCase: deleteTaskUseCase,
  );
});

// =============================================================================
// SETTINGS AND THEME PROVIDERS
// =============================================================================

/// Provider for the current theme mode
/// Manages light/dark/system theme selection with persistence
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, String>((ref) {
  final settingsBox = ref.watch(settingsBoxProvider);
  return ThemeModeNotifier(settingsBox);
});

/// Provider for the current locale
/// Manages language selection with persistence
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final settingsBox = ref.watch(settingsBoxProvider);
  return LocaleNotifier(settingsBox);
});

/// Provider for onboarding completion status
/// Tracks whether the user has completed the onboarding flow
final onboardingCompletedProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final settingsBox = ref.watch(settingsBoxProvider);
  return OnboardingNotifier(settingsBox);
});

// =============================================================================
// SETTINGS NOTIFIERS
// =============================================================================

/// Notifier for managing theme mode persistence
class ThemeModeNotifier extends StateNotifier<String> {
  final Box _settingsBox;
  
  ThemeModeNotifier(this._settingsBox) 
      : super(_settingsBox.get('theme_mode', defaultValue: 'system'));

  /// Update the theme mode and persist to storage
  Future<void> setThemeMode(String themeMode) async {
    await _settingsBox.put('theme_mode', themeMode);
    state = themeMode;
  }
}

/// Notifier for managing locale persistence
class LocaleNotifier extends StateNotifier<String> {
  final Box _settingsBox;
  
  LocaleNotifier(this._settingsBox) 
      : super(_settingsBox.get('locale', defaultValue: 'en'));

  /// Update the locale and persist to storage
  Future<void> setLocale(String locale) async {
    await _settingsBox.put('locale', locale);
    state = locale;
  }
}

/// Notifier for managing onboarding completion status
class OnboardingNotifier extends StateNotifier<bool> {
  final Box _settingsBox;
  
  OnboardingNotifier(this._settingsBox) 
      : super(_settingsBox.get('onboarding_completed', defaultValue: false));

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _settingsBox.put('onboarding_completed', true);
    state = true;
  }

  /// Reset onboarding status (for testing purposes)
  Future<void> resetOnboarding() async {
    await _settingsBox.put('onboarding_completed', false);
    state = false;
  }
}