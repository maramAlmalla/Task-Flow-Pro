/// Utility class containing validation functions for user input
/// Used across the application to ensure data integrity and provide user feedback

class Validators {
  /// Validates task title input
  /// Returns null if valid, error message if invalid
  static String? validateTaskTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Task title cannot be empty';
    }
    if (title.trim().length < 2) {
      return 'Task title must be at least 2 characters long';
    }
    if (title.trim().length > 100) {
      return 'Task title cannot exceed 100 characters';
    }
    return null;
  }

  /// Validates task description input
  /// Returns null if valid, error message if invalid
  static String? validateTaskDescription(String? description) {
    if (description != null && description.trim().length > 500) {
      return 'Task description cannot exceed 500 characters';
    }
    return null;
  }

  /// Validates that the due date is not in the past
  /// Returns null if valid, error message if invalid
  static String? validateDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return null; // Due date is optional
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDateOnly.isBefore(today)) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  /// Validates list name input
  /// Returns null if valid, error message if invalid
  static String? validateListName(String? listName) {
    if (listName == null || listName.trim().isEmpty) {
      return 'List name cannot be empty';
    }
    if (listName.trim().length < 2) {
      return 'List name must be at least 2 characters long';
    }
    if (listName.trim().length > 50) {
      return 'List name cannot exceed 50 characters';
    }
    return null;
  }

  /// Validates priority value (0: Low, 1: Medium, 2: High)
  /// Returns null if valid, error message if invalid
  static String? validatePriority(int? priority) {
    if (priority == null || priority < 0 || priority > 2) {
      return 'Invalid priority value';
    }
    return null;
  }

  /// Sanitizes user input by trimming whitespace
  static String sanitizeInput(String input) {
    return input.trim();
  }

  /// Validates email format (for future use if user accounts are added)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}