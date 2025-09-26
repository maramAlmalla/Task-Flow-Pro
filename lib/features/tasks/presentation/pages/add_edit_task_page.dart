import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_list_notifier.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/notifications/notifications_service.dart';

/// Page for adding new tasks or editing existing ones
/// Implements the View in MVVM pattern with form validation
class AddEditTaskPage extends ConsumerStatefulWidget {
  final Task? task; // Null for new task, populated for editing

  const AddEditTaskPage({super.key, this.task});

  @override
  ConsumerState<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends ConsumerState<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  int _selectedPriority = 1; // Default to medium priority
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Initialize form with existing task data if editing
  void _initializeForm() {
    if (_isEditing) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedDueDate = task.dueDate;
      _selectedDueTime = task.dueDate != null 
          ? TimeOfDay.fromDateTime(task.dueDate!) 
          : null;
      _selectedPriority = task.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'edit_task'.tr() : 'add_task'.tr()),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: Text(
              'save'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'task_title'.tr(),
                  hintText: 'enter_task_title'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: Validators.validateTaskTitle,
                textInputAction: TextInputAction.next,
                autofocus: !_isEditing,
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'task_description'.tr(),
                  hintText: 'enter_task_description'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: Validators.validateTaskDescription,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              
              const SizedBox(height: 24),
              
              // Priority selection
              Text(
                'priority'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildPrioritySelector(),
              
              const SizedBox(height: 24),
              
              // Due date and time selection
              Text(
                'due_date'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildDateTimeSelector(context),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _isEditing ? 'update_task'.tr() : 'create_task'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              // Delete button for editing
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _deleteTask,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'delete_task'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build priority selector widget
  Widget _buildPrioritySelector() {
    return Row(
      children: [
        _buildPriorityOption(0, 'low'.tr(), Colors.green, Icons.keyboard_arrow_down),
        const SizedBox(width: 12),
        _buildPriorityOption(1, 'medium'.tr(), Colors.orange, Icons.keyboard_arrow_up),
        const SizedBox(width: 12),
        _buildPriorityOption(2, 'high'.tr(), Colors.red, Icons.keyboard_double_arrow_up),
      ],
    );
  }

  /// Build individual priority option
  Widget _buildPriorityOption(int priority, String label, Color color, IconData icon) {
    final isSelected = _selectedPriority == priority;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build date and time selector
  Widget _buildDateTimeSelector(BuildContext context) {
    return Column(
      children: [
        // Date selector
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(
            _selectedDueDate != null
                ? DateFormat.yMMMd().format(_selectedDueDate!)
                : 'select_date'.tr(),
          ),
          trailing: _selectedDueDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    _selectedDueDate = null;
                    _selectedDueTime = null;
                  }),
                )
              : const Icon(Icons.arrow_forward_ios),
          onTap: _selectDate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
        
        // Time selector (only if date is selected)
        if (_selectedDueDate != null) ...[
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              _selectedDueTime != null
                  ? _selectedDueTime!.format(context)
                  : 'select_time'.tr(),
            ),
            trailing: _selectedDueTime != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedDueTime = null),
                  )
                : const Icon(Icons.arrow_forward_ios),
            onTap: _selectTime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
          ),
        ],
      ],
    );
  }

  /// Select due date
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        // Reset time when date changes
        if (_selectedDueTime == null) {
          _selectedDueTime = const TimeOfDay(hour: 9, minute: 0);
        }
      });
    }
  }

  /// Select due time
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() => _selectedDueTime = picked);
    }
  }

  /// Save task (create or update)
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final dueDate = _buildDueDateTime();

      final taskNotifier = ref.read(taskListNotifierProvider.notifier);

      if (_isEditing) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description.isEmpty ? null : description,
          dueDate: dueDate,
          priority: _selectedPriority,
          updatedAt: DateTime.now(),
        );
        await taskNotifier.updateTask(updatedTask);
      } else {
        // Create new task
        await taskNotifier.createTask(
          title: title,
          description: description.isEmpty ? null : description,
          dueDate: dueDate,
          priority: _selectedPriority,
        );
      }

      // Schedule notification if due date is set
      if (dueDate != null) {
        await _scheduleNotification(title, dueDate);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'task_updated'.tr() : 'task_created'.tr(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_saving_task'.tr() + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Delete task
  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_task'.tr()),
        content: Text('delete_task_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final taskNotifier = ref.read(taskListNotifierProvider.notifier);
        await taskNotifier.deleteTask(widget.task!.id);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('task_deleted'.tr())),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_deleting_task'.tr() + ': $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Build due date time from selected date and time
  DateTime? _buildDueDateTime() {
    if (_selectedDueDate == null) return null;

    final time = _selectedDueTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
      _selectedDueDate!.year,
      _selectedDueDate!.month,
      _selectedDueDate!.day,
      time.hour,
      time.minute,
    );
  }

  /// Schedule notification for task reminder
  Future<void> _scheduleNotification(String title, DateTime dueDate) async {
    try {
      final notificationService = NotificationsService();
      
      // Schedule notification 1 hour before due time
      final reminderTime = dueDate.subtract(const Duration(hours: 1));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(
          id: title.hashCode, // Use title hash as unique ID
          title: 'task_reminder'.tr(),
          body: '${'task'.tr()}: $title',
          scheduledDate: reminderTime,
          payload: 'task_reminder',
        );
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}