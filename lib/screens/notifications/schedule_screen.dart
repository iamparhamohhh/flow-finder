// lib/screens/notifications/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddScheduleDialog(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildCalendar(provider),
              const Divider(),
              Expanded(child: _buildSchedulesList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(NotificationProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          return provider.schedules
              .where((schedule) => _hasScheduleOnDay(schedule, day))
              .toList();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  bool _hasScheduleOnDay(PracticeSchedule schedule, DateTime day) {
    if (!schedule.isEnabled) return false;

    switch (schedule.frequency) {
      case ReminderFrequency.daily:
        return day.isAfter(
          schedule.startTime.subtract(const Duration(days: 1)),
        );
      case ReminderFrequency.weekly:
        if (day.isBefore(schedule.startTime)) return false;
        final dayOfWeek = day.weekday;
        return schedule.daysOfWeek?.contains(dayOfWeek) ?? false;
      case ReminderFrequency.once:
        return isSameDay(day, schedule.startTime);
      case ReminderFrequency.custom:
        // Custom frequency not fully implemented yet
        return false;
    }
  }

  Widget _buildSchedulesList(NotificationProvider provider) {
    final schedulesForDay = provider.schedules
        .where(
          (s) => _selectedDay != null && _hasScheduleOnDay(s, _selectedDay!),
        )
        .toList();

    if (provider.schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No schedules yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Create your first practice schedule'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Schedule'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_selectedDay != null) ...[
          Text(
            DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (schedulesForDay.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No practices scheduled for this day',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...schedulesForDay.map(
              (schedule) => _buildScheduleCard(context, provider, schedule),
            ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text('All Schedules', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        ...provider.schedules.map(
          (schedule) => _buildScheduleCard(context, provider, schedule),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    NotificationProvider provider,
    PracticeSchedule schedule,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          SwitchListTile(
            value: schedule.isEnabled,
            onChanged: (value) => provider.toggleSchedule(schedule.id, value),
            title: Text(
              schedule.practiceType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (schedule.notes != null) Text(schedule.notes!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getFrequencyIcon(schedule.frequency),
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(schedule),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.durationMinutes} minutes',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (schedule.sendReminder) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Reminder ${schedule.reminderMinutesBefore} min before',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: schedule.isEnabled
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Icon(
                Icons.calendar_today,
                color: schedule.isEnabled
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
                  onPressed: () => _showEditScheduleDialog(context, schedule),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, provider, schedule),
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

  String _getFrequencyText(PracticeSchedule schedule) {
    switch (schedule.frequency) {
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        final days =
            schedule.daysOfWeek?.map((d) => _getDayName(d)).join(', ') ??
            'Every week';
        return days;
      case ReminderFrequency.once:
        return DateFormat('MMM dd, h:mm a').format(schedule.startTime);
      case ReminderFrequency.custom:
        return 'Custom dates';
    }
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  void _showAddScheduleDialog(BuildContext context) {
    _showScheduleDialog(context, null);
  }

  void _showEditScheduleDialog(
    BuildContext context,
    PracticeSchedule schedule,
  ) {
    _showScheduleDialog(context, schedule);
  }

  void _showScheduleDialog(BuildContext context, PracticeSchedule? existing) {
    final titleController = TextEditingController(text: existing?.practiceType);
    final descController = TextEditingController(text: existing?.notes);
    ReminderFrequency frequency =
        existing?.frequency ?? ReminderFrequency.daily;
    DateTime startDate = existing?.startTime ?? DateTime.now();
    DateTime? specificDateTime = existing?.startTime;
    List<int> selectedDays = existing?.daysOfWeek ?? [];
    int duration = existing?.durationMinutes ?? 10;
    int? reminderBefore = existing?.reminderMinutesBefore;
    String? practiceType = existing?.practiceType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Schedule' : 'Edit Schedule'),
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
                if (frequency == ReminderFrequency.weekly) ...[
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
                  const SizedBox(height: 16),
                ],
                if (frequency == ReminderFrequency.once) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date & Time'),
                    subtitle: Text(
                      specificDateTime != null
                          ? DateFormat(
                              'MMM dd, h:mm a',
                            ).format(specificDateTime!)
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: specificDateTime ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            specificDateTime ?? DateTime.now(),
                          ),
                        );
                        if (time != null) {
                          setState(() {
                            specificDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Duration (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller:
                            TextEditingController(text: duration.toString())
                              ..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: duration.toString().length,
                                ),
                              ),
                        onChanged: (value) {
                          duration = int.tryParse(value) ?? 10;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Reminder before (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: reminderBefore?.toString() ?? '',
                        ),
                        onChanged: (value) {
                          reminderBefore = int.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
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

                if (existing == null) {
                  await provider.createSchedule(
                    practiceType: titleController.text,
                    startTime: specificDateTime ?? startDate,
                    durationMinutes: duration,
                    frequency: frequency,
                    daysOfWeek: frequency == ReminderFrequency.weekly
                        ? selectedDays
                        : null,
                    sendReminder: reminderBefore != null,
                    reminderMinutesBefore: reminderBefore ?? 10,
                    notes: descController.text.isEmpty
                        ? null
                        : descController.text,
                  );
                } else {
                  await provider.updateSchedule(
                    existing.copyWith(
                      practiceType: titleController.text,
                      startTime: specificDateTime ?? startDate,
                      durationMinutes: duration,
                      frequency: frequency,
                      daysOfWeek: frequency == ReminderFrequency.weekly
                          ? selectedDays
                          : null,
                      sendReminder: reminderBefore != null,
                      reminderMinutesBefore: reminderBefore ?? 10,
                      notes: descController.text.isEmpty
                          ? null
                          : descController.text,
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
    PracticeSchedule schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text(
          'Are you sure you want to delete "${schedule.practiceType}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteSchedule(schedule.id);
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
