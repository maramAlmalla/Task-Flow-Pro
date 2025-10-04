import '../repositories/reminder_repository.dart';

class DeleteReminderUseCase {
  final ReminderRepository repository;

  DeleteReminderUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteReminder(id);
  }
}
