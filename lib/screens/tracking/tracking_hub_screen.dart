import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../models/analytics_model.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/analytics_provider.dart';
import 'mood_journal_screen.dart';
import 'sleep_tracker_screen.dart';
import 'stress_monitor_screen.dart';

class TrackingHubScreen extends StatefulWidget {
  const TrackingHubScreen({super.key});

  @override
  State<TrackingHubScreen> createState() => _TrackingHubScreenState();
}

class _TrackingHubScreenState extends State<TrackingHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().initialize();
      context.read<AnalyticsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.checklist), text: 'Check-In'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
            Tab(icon: Icon(Icons.file_download), text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardTab(),
          DailyCheckInTab(),
          ReportsTab(),
          ExportTab(),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD TAB ====================

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrackingProvider, AnalyticsProvider>(
      builder: (context, trackingProvider, analyticsProvider, child) {
        final stats = trackingProvider.currentStatistics;
        final weeklyReport = analyticsProvider.weeklyReport;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              trackingProvider.refreshAll(),
              analyticsProvider.refreshAll(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quick Stats
              _buildQuickStatsCard(stats),
              const SizedBox(height: 16),
              // Tracking Options
              _buildTrackingOptionsCard(context),
              const SizedBox(height: 16),
              // Recent Insights
              if (weeklyReport != null) _buildInsightsCard(weeklyReport),
              const SizedBox(height: 16),
              // Recent Entries
              _buildRecentEntriesCard(trackingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsCard(Map<String, dynamic>? stats) {
    final avgMood = stats?['averageMoodRating'] ?? 0.0;
    final avgSleep = stats?['averageSleepHours'] ?? 0.0;
    final avgStress = stats?['averageStressLevel'] ?? 0.0;
    final improvement = stats?['moodImprovementRate'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '30-Day Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  icon: Icons.mood,
                  label: 'Avg Mood',
                  value: avgMood.toStringAsFixed(1),
                  color: _getMoodColor(avgMood),
                ),
                _buildStatColumn(
                  icon: Icons.bedtime,
                  label: 'Avg Sleep',
                  value: '${avgSleep.toStringAsFixed(1)}h',
                  color: _getSleepColor(avgSleep),
                ),
                _buildStatColumn(
                  icon: Icons.psychology,
                  label: 'Avg Stress',
                  value: avgStress.toStringAsFixed(1),
                  color: _getStressColor(avgStress),
                ),
                _buildStatColumn(
                  icon: Icons.trending_up,
                  label: 'Improvement',
                  value: '${(improvement * 100).toStringAsFixed(0)}%',
                  color: improvement > 0 ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrackingOptionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.mood,
                  label: 'Mood',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodJournalScreen(),
                    ),
                  ),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.bedtime,
                  label: 'Sleep',
                  color: Colors.indigo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SleepTrackerScreen(),
                    ),
                  ),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.psychology,
                  label: 'Stress',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StressMonitorScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(AnalyticsReport report) {
    final highPriorityInsights = report.keyInsights.take(3).toList();

    if (highPriorityInsights.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Key Insights',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...highPriorityInsights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntriesCard(TrackingProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRecentEntry(
              icon: Icons.mood,
              label: 'Mood entries',
              count: provider.recentMoodEntries.length,
              color: Colors.blue,
            ),
            _buildRecentEntry(
              icon: Icons.bedtime,
              label: 'Sleep entries',
              count: provider.recentSleepEntries.length,
              color: Colors.indigo,
            ),
            _buildRecentEntry(
              icon: Icons.psychology,
              label: 'Stress entries',
              count: provider.recentStressEntries.length,
              color: Colors.orange,
            ),
            _buildRecentEntry(
              icon: Icons.checklist,
              label: 'Daily check-ins',
              count: provider.recentCheckIns.length,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntry({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.0) return Colors.green;
    if (mood >= 3.0) return Colors.lightGreen;
    if (mood >= 2.0) return Colors.orange;
    return Colors.red;
  }

  Color _getSleepColor(double hours) {
    if (hours >= 7) return Colors.green;
    if (hours >= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getStressColor(double level) {
    if (level <= 2.0) return Colors.green;
    if (level <= 3.0) return Colors.orange;
    return Colors.red;
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.check_circle;
      case InsightType.suggestion:
        return Icons.lightbulb;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.milestone:
        return Icons.emoji_events;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.suggestion:
        return Colors.blue;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.milestone:
        return Colors.purple;
    }
  }
}

// ==================== DAILY CHECK-IN TAB ====================

class DailyCheckInTab extends StatefulWidget {
  const DailyCheckInTab({super.key});

  @override
  State<DailyCheckInTab> createState() => _DailyCheckInTabState();
}

class _DailyCheckInTabState extends State<DailyCheckInTab> {
  MoodRating _mood = MoodRating.neutral;
  StressLevel _stress = StressLevel.moderate;
  double _energy = 3.0;
  SleepQuality _lastNightSleep = SleepQuality.fair;
  int _practiceCount = 0;
  String _highlights = '';
  String _challenges = '';

  @override
  void initState() {
    super.initState();
    _loadTodayCheckIn();
  }

  Future<void> _loadTodayCheckIn() async {
    final provider = context.read<TrackingProvider>();
    final todayCheckIn = await provider.getTodayCheckIn();
    if (todayCheckIn != null && mounted) {
      setState(() {
        _mood = todayCheckIn.overallMood ?? MoodRating.neutral;
        _stress = todayCheckIn.stressLevel ?? StressLevel.moderate;
        _energy = todayCheckIn.energyLevel?.toDouble() ?? 3.0;
        _lastNightSleep = todayCheckIn.lastNightSleep ?? SleepQuality.fair;
        _practiceCount = todayCheckIn.practiceCount ?? 0;
        _highlights = todayCheckIn.highlights ?? '';
        _challenges = todayCheckIn.challenges ?? '';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.today, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMM dd').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Overall Mood
        _buildSectionCard(
          title: 'Overall Mood',
          icon: Icons.mood,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MoodRating.values.map((mood) {
              return ChoiceChip(
                label: Text('${mood.emoji} ${mood.label}'),
                selected: _mood == mood,
                onSelected: (selected) {
                  if (selected) setState(() => _mood = mood);
                },
              );
            }).toList(),
          ),
        ),
        // Stress Level
        _buildSectionCard(
          title: 'Stress Level',
          icon: Icons.psychology,
          child: Column(
            children: StressLevel.values.map((stress) {
              return RadioListTile<StressLevel>(
                title: Row(
                  children: [
                    Text(stress.emoji),
                    const SizedBox(width: 8),
                    Text(stress.label),
                  ],
                ),
                value: stress,
                groupValue: _stress,
                onChanged: (value) => setState(() => _stress = value!),
              );
            }).toList(),
          ),
        ),
        // Energy Level
        _buildSectionCard(
          title: 'Energy Level: ${_energy.toInt()}/10',
          icon: Icons.bolt,
          child: Slider(
            value: _energy,
            min: 1,
            max: 10,
            divisions: 9,
            label: _energy.toInt().toString(),
            onChanged: (value) => setState(() => _energy = value),
          ),
        ),
        // Sleep Quality
        _buildSectionCard(
          title: 'Sleep Last Night',
          icon: Icons.bedtime,
          child: Column(
            children: SleepQuality.values.map((quality) {
              return RadioListTile<SleepQuality>(
                title: Row(
                  children: [const SizedBox(width: 8), Text(quality.label)],
                ),
                value: quality,
                groupValue: _lastNightSleep,
                onChanged: (value) => setState(() => _lastNightSleep = value!),
              );
            }).toList(),
          ),
        ),
        // Practice Count
        _buildSectionCard(
          title: 'Practices Today',
          icon: Icons.self_improvement,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _practiceCount > 0
                    ? () => setState(() => _practiceCount--)
                    : null,
              ),
              Text(
                '$_practiceCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _practiceCount++),
              ),
            ],
          ),
        ),
        // Highlights
        _buildSectionCard(
          title: 'Highlights',
          icon: Icons.star,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'What went well today?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => _highlights = value,
            controller: TextEditingController(text: _highlights),
          ),
        ),
        // Challenges
        _buildSectionCard(
          title: 'Challenges',
          icon: Icons.warning_amber,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'What was difficult today?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => _challenges = value,
            controller: TextEditingController(text: _challenges),
          ),
        ),
        const SizedBox(height: 16),
        // Save Button
        ElevatedButton.icon(
          onPressed: _saveCheckIn,
          icon: const Icon(Icons.save),
          label: const Text('Save Check-In'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _saveCheckIn() async {
    final provider = context.read<TrackingProvider>();
    await provider.saveDailyCheckIn(
      overallMood: _mood,
      stressLevel: _stress,
      energyLevel: _energy.toInt(),
      lastNightSleep: _lastNightSleep,
      practiceCount: _practiceCount,
      highlights: _highlights.isEmpty ? null : _highlights,
      challenges: _challenges.isEmpty ? null : _challenges,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Daily check-in saved!')));
    }
  }
}

// ==================== REPORTS TAB ====================

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  ReportPeriod _selectedPeriod = ReportPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Period Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ReportPeriod>(
                segments: const [
                  ButtonSegment(
                    value: ReportPeriod.weekly,
                    label: Text('Week'),
                    icon: Icon(Icons.view_week),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.monthly,
                    label: Text('Month'),
                    icon: Icon(Icons.calendar_month),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.yearly,
                    label: Text('Year'),
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<ReportPeriod> newSelection) {
                  setState(() => _selectedPeriod = newSelection.first);
                  _generateReport();
                },
              ),
            ),
            // Report Content
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildReportContent(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportContent(BuildContext context, AnalyticsProvider provider) {
    AnalyticsReport? report;
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        report = provider.weeklyReport;
        break;
      case ReportPeriod.monthly:
        report = provider.monthlyReport;
        break;
      case ReportPeriod.yearly:
        report = provider.yearlyReport;
        break;
      default:
        report = provider.weeklyReport;
    }

    if (report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No report available'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Report Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedPeriod.name.toUpperCase()} REPORT',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _generateReport,
                    ),
                  ],
                ),
                Text(
                  '${DateFormat('MMM dd').format(report.startDate)} - ${DateFormat('MMM dd, yyyy').format(report.endDate)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Insights
        if (report.keyInsights.isNotEmpty) ...[
          const Text(
            'Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...report.keyInsights.take(5).map((insight) {
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                ),
                title: Text(insight),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        // Recommendations
        if (report.recommendations.isNotEmpty) ...[
          const Text(
            'Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: report.recommendations.take(5).map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.check_circle;
      case InsightType.suggestion:
        return Icons.lightbulb;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.milestone:
        return Icons.emoji_events;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.suggestion:
        return Colors.blue;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.milestone:
        return Colors.purple;
    }
  }

  Future<void> _generateReport() async {
    final provider = context.read<AnalyticsProvider>();
    switch (_selectedPeriod) {
      case ReportPeriod.weekly:
        await provider.generateWeeklyReport();
        break;
      case ReportPeriod.monthly:
        await provider.generateMonthlyReport();
        break;
      case ReportPeriod.yearly:
        await provider.generateYearlyReport();
        break;
      default:
        await provider.generateWeeklyReport();
    }
  }
}

// ==================== EXPORT TAB ====================

class ExportTab extends StatefulWidget {
  const ExportTab({super.key});

  @override
  State<ExportTab> createState() => _ExportTabState();
}

class _ExportTabState extends State<ExportTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _format = 'csv';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Your Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Export your tracking data for personal records or to share with healthcare providers',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Date Range
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start Date'),
                  subtitle: Text(
                    _startDate == null
                        ? 'Not set'
                        : DateFormat('MMM dd, yyyy').format(_startDate!),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectStartDate(context),
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('End Date'),
                  subtitle: Text(
                    _endDate == null
                        ? 'Not set'
                        : DateFormat('MMM dd, yyyy').format(_endDate!),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectEndDate(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Export Format
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Format',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RadioListTile(
                  title: const Text('CSV (Excel compatible)'),
                  subtitle: const Text('Best for data analysis'),
                  value: 'csv',
                  groupValue: _format,
                  onChanged: (value) => setState(() => _format = value!),
                ),
                RadioListTile(
                  title: const Text('JSON'),
                  subtitle: const Text('Structured data format'),
                  value: 'json',
                  groupValue: _format,
                  onChanged: (value) => setState(() => _format = value!),
                ),
                RadioListTile(
                  title: const Text('Text Report'),
                  subtitle: const Text('Human-readable summary'),
                  value: 'text',
                  groupValue: _format,
                  onChanged: (value) => setState(() => _format = value!),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Export Button
        ElevatedButton.icon(
          onPressed: _canExport() ? _exportData : null,
          icon: const Icon(Icons.file_download),
          label: const Text('Export & Share'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your data will be saved and you can share it using any app on your device',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _canExport() {
    return _startDate != null && _endDate != null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _exportData() async {
    if (!_canExport()) return;

    final provider = context.read<AnalyticsProvider>();
    String filePath;

    try {
      if (_format == 'csv') {
        filePath = await provider.exportToCSV(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      } else if (_format == 'json') {
        filePath = await provider.exportToJSON(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      } else {
        // For text, we need to generate a report first
        await provider.generateCustomReport(
          startDate: _startDate!,
          endDate: _endDate!,
        );
        final report = provider.customReport;
        if (report == null) throw Exception('Failed to generate report');
        filePath = await provider.exportReportAsText(report);
      }

      if (mounted) {
        // Show success and share
        final share = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Successful'),
            content: const Text('Would you like to share the exported file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Share'),
              ),
            ],
          ),
        );

        if (share == true) {
          await provider.shareExportedFile(filePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
