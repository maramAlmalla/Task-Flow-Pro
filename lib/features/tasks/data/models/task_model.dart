import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

/// Task model for Hive storage implementation
/// This model handles data persistence and conversion between domain entities
/// and storage format in the Clean Architecture data layer
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(5)
  bool done;

  @HiveField(6)
  String? listId;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  TaskModel({
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

  /// Convert TaskModel to domain Task entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      done: done,
      listId: listId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create TaskModel from domain Task entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      done: task.done,
      listId: task.listId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Create a copy of this model with some properties modified
  TaskModel copyWith({
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
    return TaskModel(
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

  /// Convert to JSON for debugging or future API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'done': done,
      'listId': listId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create TaskModel from JSON for debugging or future API integration
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
      priority: json['priority'] as int,
      done: json['done'] as bool,
      listId: json['listId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, priority: $priority, done: $done}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}