import 'package:hive/hive.dart';
import '../models/reminder_model.dart';

class ReminderLocalDataSource {
  final Box<ReminderModel> box;

  ReminderLocalDataSource(this.box);

  Future<List<ReminderModel>> getAllReminders() async {
    return box.values.toList();
  }

  Future<ReminderModel?> getReminderById(String id) async {
    return box.get(id);
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await box.put(reminder.id, reminder);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await box.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await box.delete(id);
  }
}
