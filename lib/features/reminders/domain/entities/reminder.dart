class Reminder {
  final String id;
  final String name;
  final DateTime time;
  final String recurrence;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reminder({
    required this.id,
    required this.name,
    required this.time,
    required this.recurrence,
    required this.notificationsEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? name,
    DateTime? time,
    String? recurrence,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      recurrence: recurrence ?? this.recurrence,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
