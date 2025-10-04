import 'package:hive/hive.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  String recurrence;

  @HiveField(4)
  bool notificationsEnabled;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  ReminderModel({
    required this.id,
    required this.name,
    required this.time,
    required this.recurrence,
    required this.notificationsEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  Reminder toEntity() {
    return Reminder(
      id: id,
      name: name,
      time: time,
      recurrence: recurrence,
      notificationsEnabled: notificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      name: reminder.name,
      time: reminder.time,
      recurrence: reminder.recurrence,
      notificationsEnabled: reminder.notificationsEnabled,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }
}
