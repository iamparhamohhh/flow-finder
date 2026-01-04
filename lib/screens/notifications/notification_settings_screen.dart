// lib/screens/notifications/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import 'reminders_screen.dart';
import 'schedule_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.settings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // Quick Access Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildQuickAccessCard(
                      context,
                      icon: Icons.alarm,
                      title: 'Smart Reminders',
                      subtitle: '${provider.reminders.length} active',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RemindersScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Practice Schedule',
                      subtitle: '${provider.schedules.length} scheduled',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScheduleScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ML Suggestions
              if (provider.mlSuggestionsEnabled &&
                  provider.mlSuggestions.isNotEmpty)
                _buildMLSuggestionsSection(context, provider),

              const Divider(),

              // Settings
              _buildSettingsSection(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMLSuggestionsSection(
    BuildContext context,
    NotificationProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'AI-Powered Suggestions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.mlSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = provider.mlSuggestions[index];
              return _buildMLSuggestionCard(context, provider, suggestion);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMLSuggestionCard(
    BuildContext context,
    NotificationProvider provider,
    suggestion,
  ) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.practiceType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatTime(suggestion.suggestedTime)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.reason,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: _getConfidenceColor(suggestion.confidence),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(suggestion.confidence * 100).toInt()}% confidence',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getConfidenceColor(suggestion.confidence),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await provider.createReminderFromSuggestion(suggestion);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder created!')),
                    );
                  }
                },
                icon: const Icon(Icons.add_alarm, size: 18),
                label: const Text('Set Reminder'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive all app notifications'),
          value: provider.notificationsEnabled,
          onChanged: (value) => provider.toggleNotifications(value),
          secondary: const Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: const Text('Streak Notifications'),
          subtitle: const Text('Get notified about milestone achievements'),
          value: provider.streakNotificationsEnabled,
          onChanged: (value) => provider.toggleStreakNotifications(value),
          secondary: const Icon(Icons.local_fire_department),
        ),
        SwitchListTile(
          title: const Text('Gentle Nudges'),
          subtitle: const Text('Helpful reminders during stress'),
          value: provider.nudgesEnabled,
          onChanged: (value) => provider.toggleNudgesGlobal(value),
          secondary: const Icon(Icons.touch_app),
        ),
        SwitchListTile(
          title: const Text('AI Suggestions'),
          subtitle: const Text('ML-powered optimal practice times'),
          value: provider.mlSuggestionsEnabled,
          onChanged: (value) => provider.toggleMLSuggestions(value),
          secondary: const Icon(Icons.psychology),
        ),
        ListTile(
          leading: const Icon(Icons.bedtime),
          title: const Text('Quiet Hours'),
          subtitle: Text(
            '${provider.settings['quietHoursStart'] ?? 22}:00 - ${provider.settings['quietHoursEnd'] ?? 8}:00',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showQuietHoursDialog(context, provider),
        ),
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Manage Gentle Nudges'),
          subtitle: Text('${provider.nudges.length} nudge types'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showNudgesDialog(context, provider),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.grey;
  }

  void _showQuietHoursDialog(
    BuildContext context,
    NotificationProvider provider,
  ) {
    int startHour = provider.settings['quietHoursStart'] ?? 22;
    int endHour = provider.settings['quietHoursEnd'] ?? 8;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Quiet Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No notifications during these hours'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Start: '),
                  DropdownButton<int>(
                    value: startHour,
                    items: List.generate(24, (i) => i).map((hour) {
                      return DropdownMenuItem(
                        value: hour,
                        child: Text('${hour.toString().padLeft(2, '0')}:00'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => startHour = value!);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('End:   '),
                  DropdownButton<int>(
                    value: endHour,
                    items: List.generate(24, (i) => i).map((hour) {
                      return DropdownMenuItem(
                        value: hour,
                        child: Text('${hour.toString().padLeft(2, '0')}:00'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => endHour = value!);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setQuietHours(startHour, endHour);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNudgesDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gentle Nudges'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.nudges.length,
            itemBuilder: (context, index) {
              final nudge = provider.nudges[index];
              return SwitchListTile(
                title: Text(_getNudgeTitle(nudge.trigger)),
                subtitle: Text(nudge.message),
                value: nudge.isEnabled,
                onChanged: (value) {
                  provider.toggleNudge(nudge.id, value);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getNudgeTitle(trigger) {
    switch (trigger.toString()) {
      case 'NudgeTrigger.stressDetection':
        return 'Stress Detection';
      case 'NudgeTrigger.inactivity':
        return 'Inactivity Reminder';
      case 'NudgeTrigger.timeOfDay':
        return 'Daily Morning';
      case 'NudgeTrigger.heartRate':
        return 'Heart Rate Alert';
      default:
        return 'Nudge';
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart Notifications'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🤖 AI-Powered Suggestions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Machine learning analyzes your practice history to suggest optimal times.',
              ),
              SizedBox(height: 12),
              Text(
                '🔥 Streak Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Celebrate your consistency with milestone achievements.'),
              SizedBox(height: 12),
              Text(
                '💆 Gentle Nudges',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Contextual reminders when you might need a practice most.'),
              SizedBox(height: 12),
              Text(
                '📅 Custom Schedules',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Plan your practice sessions with flexible recurring schedules.',
              ),
            ],
          ),
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
