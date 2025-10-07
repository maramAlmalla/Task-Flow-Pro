import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/reminder.dart';
import '../../../../core/di/di.dart';

class AddEditReminderPage extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddEditReminderPage({super.key, this.reminder});

  @override
  ConsumerState<AddEditReminderPage> createState() => _AddEditReminderPageState();
}

class _AddEditReminderPageState extends ConsumerState<AddEditReminderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _selectedDateTime;
  late String _selectedRecurrence;
  late bool _notificationsEnabled;

  final List<String> _recurrenceOptions = ['once', 'daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reminder?.name ?? '');
    _selectedDateTime = widget.reminder?.time ?? DateTime.now().add(const Duration(hours: 1));
    _selectedRecurrence = widget.reminder?.recurrence ?? 'once';
    _notificationsEnabled = widget.reminder?.notificationsEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        time: _selectedDateTime,
        recurrence: _selectedRecurrence,
        notificationsEnabled: _notificationsEnabled,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        await ref.read(reminderListNotifierProvider.notifier).createReminder(reminder);
      } else {
        await ref.read(reminderListNotifierProvider.notifier).editReminder(reminder);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'edit_reminder'.tr() : 'add_reminder'.tr()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'reminder_name'.tr(),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_reminder_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('date'.tr()),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('time'.tr()),
              subtitle: Text(DateFormat.jm().format(_selectedDateTime)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRecurrence,
              decoration: InputDecoration(
                labelText: 'recurrence'.tr(),
                border: const OutlineInputBorder(),
              ),
              items: _recurrenceOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.tr()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRecurrence = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('enable_notifications'.tr()),
              subtitle: Text('notification_description'.tr()),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveReminder,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isEditing ? 'update_reminder'.tr() : 'create_reminder'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
