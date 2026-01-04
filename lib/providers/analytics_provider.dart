import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';
import '../services/export_service.dart';

/// Provider for managing analytics and reports
/// Handles report generation, trend analysis, insights, and data export
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  final ExportService _exportService;

  // Cached reports
  AnalyticsReport? _weeklyReport;
  AnalyticsReport? _monthlyReport;
  AnalyticsReport? _quarterlyReport;
  AnalyticsReport? _yearlyReport;
  AnalyticsReport? _customReport;

  // Cached trends
  TrendAnalysis? _moodTrend;
  TrendAnalysis? _sleepTrend;
  TrendAnalysis? _stressTrend;

  bool _isLoading = false;
  String? _error;
  DateTime? _lastReportGeneration;

  AnalyticsProvider({
    AnalyticsService? analyticsService,
    ExportService? exportService,
  }) : _analyticsService = analyticsService ?? AnalyticsService(),
       _exportService = exportService ?? ExportService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalyticsReport? get weeklyReport => _weeklyReport;
  AnalyticsReport? get monthlyReport => _monthlyReport;
  AnalyticsReport? get quarterlyReport => _quarterlyReport;
  AnalyticsReport? get yearlyReport => _yearlyReport;
  AnalyticsReport? get customReport => _customReport;
  TrendAnalysis? get moodTrend => _moodTrend;
  TrendAnalysis? get sleepTrend => _sleepTrend;
  TrendAnalysis? get stressTrend => _stressTrend;
  DateTime? get lastReportGeneration => _lastReportGeneration;

  /// Initialize provider by generating initial reports
  Future<void> initialize() async {
    await generateWeeklyReport();
  }

  // ==================== REPORT GENERATION ====================

  /// Generate weekly report
  Future<void> generateWeeklyReport() async {
    _setLoading(true);
    _clearError();

    try {
      _weeklyReport = await _analyticsService.generateReport(
        period: ReportPeriod.weekly,
      );
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate weekly report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate monthly report
  Future<void> generateMonthlyReport() async {
    _setLoading(true);
    _clearError();

    try {
      _monthlyReport = await _analyticsService.generateReport(
        period: ReportPeriod.monthly,
      );
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate monthly report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate quarterly report
  Future<void> generateQuarterlyReport() async {
    _setLoading(true);
    _clearError();

    try {
      _quarterlyReport = await _analyticsService.generateReport(
        period: ReportPeriod.quarterly,
      );
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate quarterly report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate yearly report
  Future<void> generateYearlyReport() async {
    _setLoading(true);
    _clearError();

    try {
      _yearlyReport = await _analyticsService.generateReport(
        period: ReportPeriod.yearly,
      );
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate yearly report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate custom report for specific date range
  Future<void> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _customReport = await _analyticsService.generateReport(
        period: ReportPeriod.weekly,
        customStartDate: startDate,
        customEndDate: endDate,
      );
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate custom report: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate all standard reports (weekly, monthly, quarterly, yearly)
  Future<void> generateAllReports() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _generateWeeklyReportInternal(),
        _generateMonthlyReportInternal(),
        _generateQuarterlyReportInternal(),
        _generateYearlyReportInternal(),
      ]);
      _lastReportGeneration = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate all reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _generateWeeklyReportInternal() async {
    _weeklyReport = await _analyticsService.generateReport(
      period: ReportPeriod.weekly,
    );
  }

  Future<void> _generateMonthlyReportInternal() async {
    _monthlyReport = await _analyticsService.generateReport(
      period: ReportPeriod.monthly,
    );
  }

  Future<void> _generateQuarterlyReportInternal() async {
    _quarterlyReport = await _analyticsService.generateReport(
      period: ReportPeriod.quarterly,
    );
  }

  Future<void> _generateYearlyReportInternal() async {
    _yearlyReport = await _analyticsService.generateReport(
      period: ReportPeriod.yearly,
    );
  }

  // ==================== TREND ANALYSIS ====================

  /// Calculate mood trend for date range
  Future<void> calculateMoodTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _moodTrend = await _analyticsService.calculateTrend(
        metric: 'mood',
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to calculate mood trend: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate sleep trend for date range
  Future<void> calculateSleepTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _sleepTrend = await _analyticsService.calculateTrend(
        metric: 'sleep',
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to calculate sleep trend: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate stress trend for date range
  Future<void> calculateStressTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _stressTrend = await _analyticsService.calculateTrend(
        metric: 'stress',
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to calculate stress trend: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate all trends for a date range
  Future<void> calculateAllTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _calculateMoodTrendInternal(startDate, endDate),
        _calculateSleepTrendInternal(startDate, endDate),
        _calculateStressTrendInternal(startDate, endDate),
      ]);
      notifyListeners();
    } catch (e) {
      _setError('Failed to calculate all trends: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _calculateMoodTrendInternal(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _moodTrend = await _analyticsService.calculateTrend(
      metric: 'mood',
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _calculateSleepTrendInternal(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _sleepTrend = await _analyticsService.calculateTrend(
      metric: 'sleep',
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _calculateStressTrendInternal(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _stressTrend = await _analyticsService.calculateTrend(
      metric: 'stress',
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== DATA EXPORT ====================

  /// Export data to CSV
  Future<String> exportToCSV({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final filePath = await _exportService.exportToCSV(
        userId: 'user',
        startDate: startDate,
        endDate: endDate,
      );
      return filePath;
    } catch (e) {
      _setError('Failed to export to CSV: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Export data to JSON
  Future<String> exportToJSON({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final filePath = await _exportService.exportToJSON(
        userId: 'user',
        startDate: startDate,
        endDate: endDate,
      );
      return filePath;
    } catch (e) {
      _setError('Failed to export to JSON: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Export report as formatted text
  Future<String> exportReportAsText(AnalyticsReport report) async {
    _setLoading(true);
    _clearError();

    try {
      final filePath = await _exportService.exportReportAsText(report);
      return filePath;
    } catch (e) {
      _setError('Failed to export report: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Share exported file
  Future<void> shareExportedFile(String filePath) async {
    _setLoading(true);
    _clearError();

    try {
      await _exportService.shareExportedFile(filePath);
    } catch (e) {
      _setError('Failed to share file: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== INSIGHTS ====================

  /// Get insights from a report
  List<String> getInsights(AnalyticsReport? report) {
    return report?.keyInsights ?? [];
  }

  /// Get high priority insights
  List<String> getHighPriorityInsights(AnalyticsReport? report) {
    return report?.keyInsights.take(3).toList() ?? [];
  }

  /// Get insights by type (recommendations or key insights)
  List<String> getRecommendations(AnalyticsReport? report) {
    return report?.recommendations ?? [];
  }

  // ==================== STATISTICS ====================

  /// Get practice statistics from a report
  Map<String, dynamic>? getPracticeStats(AnalyticsReport? report) {
    if (report == null) return null;
    return {
      'total': report.totalPractices,
      'minutes': report.totalMinutes,
      'breakdown': report.practiceTypeBreakdown,
    };
  }

  /// Get mood statistics from a report
  Map<String, dynamic>? getMoodStats(AnalyticsReport? report) {
    if (report == null) return null;
    return {
      'average': report.averageMoodRating,
      'improvement': report.moodImprovement,
      'trend': report.moodTrend,
    };
  }

  /// Get sleep statistics from a report
  Map<String, dynamic>? getSleepStats(AnalyticsReport? report) {
    if (report == null) return null;
    return {
      'averageHours': report.averageSleepHours,
      'averageQuality': report.averageSleepQuality,
      'trend': report.sleepTrend,
    };
  }

  /// Get stress statistics from a report
  Map<String, dynamic>? getStressStats(AnalyticsReport? report) {
    if (report == null) return null;
    return {
      'average': report.averageStressLevel,
      'trend': report.stressTrend,
      'triggers': report.topStressTriggers,
    };
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all cached reports and trends
  void clearCache() {
    _weeklyReport = null;
    _monthlyReport = null;
    _quarterlyReport = null;
    _yearlyReport = null;
    _customReport = null;
    _moodTrend = null;
    _sleepTrend = null;
    _stressTrend = null;
    _lastReportGeneration = null;
    notifyListeners();
  }

  /// Refresh all data (regenerate current reports)
  Future<void> refreshAll() async {
    await initialize();
  }

  /// Check if reports need regeneration (older than 1 hour)
  bool needsRegeneration() {
    if (_lastReportGeneration == null) return true;
    final hoursSinceLastGeneration = DateTime.now()
        .difference(_lastReportGeneration!)
        .inHours;
    return hoursSinceLastGeneration >= 1;
  }
}
