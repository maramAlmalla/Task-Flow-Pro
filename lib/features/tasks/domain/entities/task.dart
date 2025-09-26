/// Task entity representing a task in the domain layer
/// This is the core business entity that defines what a Task is
/// Independent of any external frameworks or data storage mechanisms
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 0: Low, 1: Medium, 2: High
  final bool done;
  final String? listId; // For future multiple lists feature
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.done,
    this.listId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this task with some properties modified
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? done,
    String? listId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      done: done ?? this.done,
      listId: listId ?? this.listId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get priority as a human-readable string
  String get priorityString {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Check if the task is overdue
  bool get isOverdue {
    if (dueDate == null || done) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if the task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDueDate.isAtSameMomentAs(today);
  }

  /// Check if the task is due this week
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek) && dueDate!.isBefore(endOfWeek);
  }

  /// Convert task to string representation for debugging
  @override
  String toString() {
    return 'Task{id: $id, title: $title, priority: $priorityString, done: $done, dueDate: $dueDate}';
  }

  /// Check equality based on ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  /// Hash code based on ID
  @override
  int get hashCode => id.hashCode;
}