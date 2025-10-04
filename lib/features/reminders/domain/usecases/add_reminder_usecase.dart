import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class AddReminderUseCase {
  final ReminderRepository repository;

  AddReminderUseCase(this.repository);

  Future<void> call(Reminder reminder) async {
    await repository.addReminder(reminder);
  }
}
