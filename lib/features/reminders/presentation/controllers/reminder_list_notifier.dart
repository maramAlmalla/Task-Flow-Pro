import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/add_reminder_usecase.dart';
import '../../domain/usecases/update_reminder_usecase.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';

class ReminderListState {
  final bool isLoading;
  final List<Reminder> reminders;
  final String? error;

  ReminderListState({
    this.isLoading = false,
    this.reminders = const [],
    this.error,
  });

  ReminderListState copyWith({
    bool? isLoading,
    List<Reminder>? reminders,
    String? error,
  }) {
    return ReminderListState(
      isLoading: isLoading ?? this.isLoading,
      reminders: reminders ?? this.reminders,
      error: error,
    );
  }
}

class ReminderListNotifier extends StateNotifier<ReminderListState> {
  final GetRemindersUseCase getRemindersUseCase;
  final AddReminderUseCase addReminderUseCase;
  final UpdateReminderUseCase updateReminderUseCase;
  final DeleteReminderUseCase deleteReminderUseCase;

  ReminderListNotifier({
    required this.getRemindersUseCase,
    required this.addReminderUseCase,
    required this.updateReminderUseCase,
    required this.deleteReminderUseCase,
  }) : super(ReminderListState());

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminders = await getRemindersUseCase();
      reminders.sort((a, b) => a.time.compareTo(b.time));
      state = state.copyWith(isLoading: false, reminders: reminders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createReminder(Reminder reminder) async {
    try {
      await addReminderUseCase(reminder);
      await loadReminders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> editReminder(Reminder reminder) async {
    try {
      await updateReminderUseCase(reminder);
      await loadReminders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeReminder(String id) async {
    try {
      await deleteReminderUseCase(id);
      await loadReminders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleNotifications(String id, bool enabled) async {
    final reminder = state.reminders.firstWhere((r) => r.id == id);
    final updated = reminder.copyWith(
      notificationsEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await editReminder(updated);
  }
}
