import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadRecentSleepEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRecentSleepEntries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final sleepEntries = provider.recentSleepEntries;

          if (sleepEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bedtime, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No sleep entries yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your sleep to see how practices affect rest',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSleepDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Sleep Entry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics Card
              _buildStatisticsCard(provider),
              // Sleep Entries List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadRecentSleepEntries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sleepEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sleepEntries[index];
                      return _buildSleepEntryCard(context, entry, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSleepDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildStatisticsCard(TrackingProvider provider) {
    final stats = provider.currentStatistics;
    final avgSleepHours = stats?['averageSleepHours'] ?? 0.0;
    final avgQuality = stats?['averageSleepQuality'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.access_time,
              label: 'Avg Hours',
              value: '${avgSleepHours.toStringAsFixed(1)}h',
              color: _getSleepHoursColor(avgSleepHours),
            ),
            _buildStatItem(
              icon: Icons.star,
              label: 'Avg Quality',
              value: avgQuality.toStringAsFixed(1),
              color: _getQualityColor(avgQuality),
            ),
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Entries',
              value: provider.recentSleepEntries.length.toString(),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSleepEntryCard(
    BuildContext context,
    SleepEntry entry,
    TrackingProvider provider,
  ) {
    final duration = entry.totalSleepDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSleepDetailsDialog(context, entry, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(entry.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Quality stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < entry.quality.stars
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sleep duration
              Row(
                children: [
                  const Icon(Icons.bedtime, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${hours}h ${minutes}m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (entry.feltRested == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Rested',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Bed time and wake time
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInfo(
                      '🌙 Bedtime',
                      DateFormat('HH:mm').format(entry.bedtime),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeInfo(
                      '☀️ Wake',
                      DateFormat('HH:mm').format(entry.wakeTime),
                    ),
                  ),
                ],
              ),
              // Awakened count
              if (entry.awakeDuringNight != null &&
                  entry.awakeDuringNight! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Awakened ${entry.awakeDuringNight!} time${entry.awakeDuringNight! > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
              // Practices before sleep
              if (entry.practicesBeforeSleep.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.self_improvement, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.practicesBeforeSleep.join(', '),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getSleepHoursColor(double hours) {
    if (hours >= 7) return Colors.green;
    if (hours >= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityColor(double quality) {
    if (quality >= 4.0) return Colors.green;
    if (quality >= 3.0) return Colors.lightGreen;
    if (quality >= 2.0) return Colors.orange;
    return Colors.red;
  }

  void _showAddSleepDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddSleepEntrySheet(),
    );
  }

  void _showSleepDetailsDialog(
    BuildContext context,
    SleepEntry entry,
    TrackingProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          SleepDetailsDialog(entry: entry, provider: provider),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Tracker'),
        content: const Text(
          'Track your sleep patterns and see how mindfulness practices improve your rest.\n\n'
          '• Log bedtime and wake time\n'
          '• Rate sleep quality 1-5 stars\n'
          '• Track practices before sleep\n'
          '• View correlations',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD SLEEP ENTRY SHEET ====================

class AddSleepEntrySheet extends StatefulWidget {
  const AddSleepEntrySheet({super.key});

  @override
  State<AddSleepEntrySheet> createState() => _AddSleepEntrySheetState();
}

class _AddSleepEntrySheetState extends State<AddSleepEntrySheet> {
  DateTime? _bedTime;
  DateTime? _wakeTime;
  SleepQuality _quality = SleepQuality.fair;
  int _timesAwakened = 0;
  bool _feltRested = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Sleep Entry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Bed time
            ListTile(
              leading: const Icon(Icons.bedtime),
              title: const Text('Bedtime'),
              subtitle: Text(
                _bedTime == null
                    ? 'Not set'
                    : DateFormat('MMM dd, HH:mm').format(_bedTime!),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectBedTime(context),
            ),
            const Divider(),
            // Wake time
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Wake time'),
              subtitle: Text(
                _wakeTime == null
                    ? 'Not set'
                    : DateFormat('MMM dd, HH:mm').format(_wakeTime!),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectWakeTime(context),
            ),
            const SizedBox(height: 16),
            // Sleep quality
            const Text(
              'Sleep Quality',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildQualitySelector(),
            const SizedBox(height: 16),
            // Times awakened
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Times awakened', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _timesAwakened > 0
                          ? () => setState(() => _timesAwakened--)
                          : null,
                    ),
                    Text(
                      '$_timesAwakened',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _timesAwakened++),
                    ),
                  ],
                ),
              ],
            ),
            // Felt rested
            SwitchListTile(
              title: const Text('I felt rested'),
              value: _feltRested,
              onChanged: (value) => setState(() => _feltRested = value),
            ),
            const SizedBox(height: 16),
            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any dreams? Sleep issues?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSave() ? _saveSleepEntry : null,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: SleepQuality.values.map((quality) {
        final isSelected = _quality == quality;
        return InkWell(
          onTap: () => setState(() => _quality = quality),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: List.generate(quality.stars, (index) {
                    return const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  quality.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _canSave() {
    return _bedTime != null && _wakeTime != null;
  }

  Future<void> _selectBedTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _bedTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectWakeTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _wakeTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveSleepEntry() async {
    if (!_canSave()) return;

    final provider = context.read<TrackingProvider>();
    await provider.addSleepEntry(
      bedtime: _bedTime!,
      wakeTime: _wakeTime!,
      quality: _quality,
      awakeDuringNight: _timesAwakened,
      feltRested: _feltRested,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sleep entry saved!')));
    }
  }
}

// ==================== SLEEP DETAILS DIALOG ====================

class SleepDetailsDialog extends StatelessWidget {
  final SleepEntry entry;
  final TrackingProvider provider;

  const SleepDetailsDialog({
    super.key,
    required this.entry,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final duration = entry.totalSleepDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return AlertDialog(
      title: Text(DateFormat('MMM dd, yyyy').format(entry.date)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Duration:', '${hours}h ${minutes}m'),
            _buildDetailRow('Quality:', entry.quality.label),
            _buildDetailRow(
              'Bedtime:',
              DateFormat('HH:mm').format(entry.bedtime),
            ),
            _buildDetailRow(
              'Wake time:',
              DateFormat('HH:mm').format(entry.wakeTime),
            ),
            _buildDetailRow(
              'Times awakened:',
              entry.awakeDuringNight?.toString() ?? '0',
            ),
            _buildDetailRow(
              'Felt rested:',
              entry.feltRested == true ? 'Yes' : 'No',
              color: entry.feltRested == true ? Colors.green : null,
            ),
            if (entry.practicesBeforeSleep.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Practices before sleep:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...entry.practicesBeforeSleep.map(
                (practice) => Text('• $practice'),
              ),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(entry.notes!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Entry'),
                content: const Text(
                  'Are you sure you want to delete this sleep entry?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await provider.deleteSleepEntry(entry.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep entry deleted')),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
