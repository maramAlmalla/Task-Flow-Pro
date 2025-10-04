import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class UpdateReminderUseCase {
  final ReminderRepository repository;

  UpdateReminderUseCase(this.repository);

  Future<void> call(Reminder reminder) async {
    await repository.updateReminder(reminder);
  }
}
