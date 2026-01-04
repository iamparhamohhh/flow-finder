// lib/screens/notifications/reminders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No reminders yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Create your first smart reminder'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddReminderDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Reminder'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReminders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = provider.reminders[index];
                return _buildReminderCard(context, provider, reminder);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    NotificationProvider provider,
    SmartReminder reminder,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          SwitchListTile(
            value: reminder.isEnabled,
            onChanged: (value) => provider.toggleReminder(reminder.id, value),
            title: Text(
              reminder.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (reminder.description != null) Text(reminder.description!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getFrequencyIcon(reminder.frequency),
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(reminder),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (reminder.useMLSuggestion) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 14,
                        color: Colors.purple[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI-optimized time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: reminder.isEnabled
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Icon(
                Icons.alarm,
                color: reminder.isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditReminderDialog(context, reminder),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, provider, reminder),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFrequencyIcon(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.daily:
        return Icons.today;
      case ReminderFrequency.weekly:
        return Icons.date_range;
      case ReminderFrequency.once:
        return Icons.event;
      case ReminderFrequency.custom:
        return Icons.schedule;
    }
  }

  String _getFrequencyText(SmartReminder reminder) {
    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        final time = reminder.specificTime != null
            ? DateFormat('h:mm a').format(reminder.specificTime!)
            : 'AI-optimized';
        return 'Daily at $time';
      case ReminderFrequency.weekly:
        final days =
            reminder.daysOfWeek?.map((d) => _getDayName(d)).join(', ') ??
            'Every week';
        return days;
      case ReminderFrequency.once:
        return reminder.specificTime != null
            ? DateFormat('MMM dd, h:mm a').format(reminder.specificTime!)
            : 'One time';
      case ReminderFrequency.custom:
        return 'Custom schedule';
    }
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  void _showAddReminderDialog(BuildContext context) {
    _showReminderDialog(context, null);
  }

  void _showEditReminderDialog(BuildContext context, SmartReminder reminder) {
    _showReminderDialog(context, reminder);
  }

  void _showReminderDialog(BuildContext context, SmartReminder? existing) {
    final titleController = TextEditingController(text: existing?.title);
    final descController = TextEditingController(text: existing?.description);
    ReminderFrequency frequency =
        existing?.frequency ?? ReminderFrequency.daily;
    bool useML = existing?.useMLSuggestion ?? false;
    TimeOfDay? selectedTime = existing?.specificTime != null
        ? TimeOfDay.fromDateTime(existing!.specificTime!)
        : null;
    List<int> selectedDays = existing?.daysOfWeek ?? [];
    String? practiceType = existing?.practiceType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Reminder' : 'Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReminderFrequency>(
                  value: frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: ReminderFrequency.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(_formatFrequency(f)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => frequency = value!);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Use AI Suggestions'),
                  subtitle: const Text('Let ML find optimal time'),
                  value: useML,
                  onChanged: (value) {
                    setState(() => useML = value);
                  },
                ),
                if (!useML) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
                if (frequency == ReminderFrequency.weekly) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Days of Week:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = selectedDays.contains(day);
                      return FilterChip(
                        label: Text(_getDayName(day)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                final provider = context.read<NotificationProvider>();
                final now = DateTime.now();
                final time = selectedTime != null
                    ? DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      )
                    : null;

                if (existing == null) {
                  await provider.createReminder(
                    title: titleController.text,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                    frequency: frequency,
                    daysOfWeek: frequency == ReminderFrequency.weekly
                        ? selectedDays
                        : null,
                    specificTime: time,
                    useMLSuggestion: useML,
                    practiceType: practiceType,
                  );
                } else {
                  await provider.updateReminder(
                    existing.copyWith(
                      title: titleController.text,
                      description: descController.text.isEmpty
                          ? null
                          : descController.text,
                      frequency: frequency,
                      daysOfWeek: frequency == ReminderFrequency.weekly
                          ? selectedDays
                          : null,
                      specificTime: time,
                      useMLSuggestion: useML,
                      practiceType: practiceType,
                    ),
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFrequency(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  void _confirmDelete(
    BuildContext context,
    NotificationProvider provider,
    SmartReminder reminder,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
