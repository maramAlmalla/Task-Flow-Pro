import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/reminder.dart';
import '../../../../core/di/di.dart';
import '../pages/add_edit_reminder_page.dart';

class ReminderCard extends ConsumerWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isPast = reminder.time.isBefore(now);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditReminderPage(reminder: reminder),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'edit'.tr(),
          ),
          SlidableAction(
            onPressed: (context) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('delete_reminder'.tr()),
                  content: Text('delete_reminder_confirmation'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('cancel'.tr()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('delete'.tr()),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(reminderListNotifierProvider.notifier).removeReminder(reminder.id);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'delete'.tr(),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(
            Icons.alarm,
            color: isPast ? Colors.grey : Theme.of(context).primaryColor,
          ),
          title: Text(
            reminder.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(DateFormat.yMMMd().add_jm().format(reminder.time)),
              Text(reminder.recurrence.tr()),
            ],
          ),
          trailing: Switch(
            value: reminder.notificationsEnabled,
            onChanged: (value) {
              ref.read(reminderListNotifierProvider.notifier).toggleNotifications(
                reminder.id,
                value,
              );
            },
          ),
        ),
      ),
    );
  }
}
