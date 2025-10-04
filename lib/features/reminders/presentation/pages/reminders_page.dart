import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/di.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_page.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reminderListNotifierProvider.notifier).loadReminders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('reminders'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reminderListNotifierProvider.notifier).loadReminders(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.reminders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'no_reminders_yet'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'add_first_reminder'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reminders.length,
                      itemBuilder: (context, index) {
                        return ReminderCard(reminder: state.reminders[index]);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditReminderPage()),
          );
        },
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
