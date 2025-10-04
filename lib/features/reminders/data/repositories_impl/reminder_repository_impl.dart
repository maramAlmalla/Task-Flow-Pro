import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_data_source.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl(this.localDataSource);

  @override
  Future<List<Reminder>> getAllReminders() async {
    final models = await localDataSource.getAllReminders();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    final model = await localDataSource.getReminderById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await localDataSource.addReminder(model);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await localDataSource.updateReminder(model);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await localDataSource.deleteReminder(id);
  }
}
