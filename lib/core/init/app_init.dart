import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../notifications/notifications_service.dart';
import '../../features/tasks/data/models/task_model.dart';

/// Application initialization class
/// Handles all startup operations including Hive setup, notifications,
/// and initial data seeding for the Clean Architecture application
class AppInit {
  static bool _isInitialized = false;

  /// Initialize the application
  /// This method should be called before runApp() in main.dart
  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Hive for local storage
      await _initHive();

      // Initialize notifications service
      await _initNotifications();

      // Setup initial data if needed
      await _setupInitialData();

      _isInitialized = true;
      print('App initialization completed successfully');
    } catch (e) {
      print('Error during app initialization: $e');
      rethrow;
    }
  }

  /// Initialize Hive database and register adapters
  static Future<void> _initHive() async {
    await Hive.initFlutter();

    // Register the TaskModel adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // Open required boxes
    await _openHiveBoxes();
  }

  /// Open all required Hive boxes
  static Future<void> _openHiveBoxes() async {
    // Open tasks box for storing TaskModel objects
    if (!Hive.isBoxOpen('tasks_box')) {
      await Hive.openBox<TaskModel>('tasks_box');
    }

    // Open settings box for storing app preferences
    if (!Hive.isBoxOpen('settings_box')) {
      await Hive.openBox('settings_box');
    }
  }

  /// Initialize notifications service
  static Future<void> _initNotifications() async {
    final notificationsService = NotificationsService();
    await notificationsService.init();
  }

  /// Setup initial data for development and demo purposes
  static Future<void> _setupInitialData() async {
    final settingsBox = Hive.box('settings_box');
    final tasksBox = Hive.box<TaskModel>('tasks_box');

    // Check if this is the first run
    final isFirstRun = settingsBox.get('first_run', defaultValue: true);

    if (isFirstRun) {
      // Set default theme mode
      await settingsBox.put('theme_mode', 'system');
      
      // Set default locale
      await settingsBox.put('locale', 'en');
      
      // Mark onboarding as not completed
      await settingsBox.put('onboarding_completed', false);

      // Add sample tasks for development/demo
      if (kDebugMode) {
        await _addSampleTasks(tasksBox);
      }

      // Mark first run as completed
      await settingsBox.put('first_run', false);
      
      print('Initial data setup completed');
    }
  }

  /// Add sample tasks for development and demonstration
  static Future<void> _addSampleTasks(Box<TaskModel> tasksBox) async {
    final now = DateTime.now();
    
    final sampleTasks = [
      TaskModel(
        id: '1',
        title: 'Welcome to your Todo App',
        description: 'This is a sample task to get you started. You can edit or delete it.',
        dueDate: now.add(const Duration(days: 1)),
        priority: 1, // Medium priority
        done: false,
        listId: 'default',
        createdAt: now,
      ),
      TaskModel(
        id: '2',
        title: 'Try the calendar view',
        description: 'Check out the calendar to see your tasks organized by date.',
        dueDate: now.add(const Duration(days: 2)),
        priority: 0, // Low priority
        done: false,
        listId: 'default',
        createdAt: now,
      ),
      TaskModel(
        id: '3',
        title: 'Customize your theme',
        description: 'Go to settings to choose between light, dark, or system theme.',
        dueDate: null,
        priority: 2, // High priority
        done: false,
        listId: 'default',
        createdAt: now,
      ),
      TaskModel(
        id: '4',
        title: 'Set up notifications',
        description: 'Enable notifications to get reminders for your important tasks.',
        dueDate: now.add(const Duration(hours: 3)),
        priority: 1, // Medium priority
        done: false,
        listId: 'default',
        createdAt: now,
      ),
      TaskModel(
        id: '5',
        title: 'Completed task example',
        description: 'This shows how completed tasks look in your list.',
        dueDate: now.subtract(const Duration(days: 1)),
        priority: 0, // Low priority
        done: true,
        listId: 'default',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final task in sampleTasks) {
      await tasksBox.put(task.id, task);
    }

    print('Added ${sampleTasks.length} sample tasks');
  }

  /// Get the current theme mode from settings
  static String getThemeMode() {
    if (!_isInitialized) {
      return 'system';
    }
    
    final settingsBox = Hive.box('settings_box');
    return settingsBox.get('theme_mode', defaultValue: 'system');
  }

  /// Get the current locale from settings
  static String getLocale() {
    if (!_isInitialized) {
      return 'en';
    }
    
    final settingsBox = Hive.box('settings_box');
    return settingsBox.get('locale', defaultValue: 'en');
  }

  /// Check if onboarding has been completed
  static bool isOnboardingCompleted() {
    if (!_isInitialized) {
      return false;
    }
    
    final settingsBox = Hive.box('settings_box');
    return settingsBox.get('onboarding_completed', defaultValue: false);
  }

  /// Clean up resources on app termination
  static Future<void> dispose() async {
    await Hive.close();
    print('App resources cleaned up');
  }
}