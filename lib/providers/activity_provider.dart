// lib/providers/activity_provider.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';
import 'quest_provider.dart'; // ✅ اضافه شد
import '../models/quest_model.dart'; // ✅ اضافه شد

class ActivityProvider extends ChangeNotifier {
  Box<Activity>? _activityBox;
  List<Activity> _activities = [];
  QuestProvider? _questProvider; // ✅ اضافه شد

  List<Activity> get activities => _activities;

  // ✅ متد جدید برای تزریق QuestProvider
  void setQuestProvider(QuestProvider questProvider) {
    _questProvider = questProvider;
  }

  // Initialize provider
  Future<void> init() async {
    _activityBox = await Hive.openBox<Activity>('activities');
    _loadActivities();
  }

  // بارگذاری فعالیت‌ها از Hive
  void _loadActivities() {
    if (_activityBox != null) {
      _activities = _activityBox!.values.toList();
      notifyListeners();
    }
  }

  // ✅ افزودن فعالیت جدید + آپدیت Quest
  Future<void> addActivity(Activity activity) async {
    if (_activityBox == null) {
      await init();
    }
    await _activityBox!.put(activity.id, activity);
    _loadActivities();
    
    // ✅ آپدیت Quest اگر Provider موجود باشه
    _questProvider?.updateQuestProgress(QuestType.flowChart);
  }

  // به‌روزرسانی فعالیت
  Future<void> updateActivity(Activity activity) async {
    if (_activityBox == null) {
      await init();
    }
    await _activityBox!.put(activity.id, activity);
    _loadActivities();
  }

  // حذف فعالیت
  Future<void> deleteActivity(String id) async {
    if (_activityBox == null) {
      await init();
    }
    await _activityBox!.delete(id);
    _loadActivities();
  }

  // پیدا کردن فعالیت با ID
  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ آمار جدید برای Flow Activities
  int get flowActivities {
    return _activities.where((a) => a.flowState == 'Flow').length;
  }

  double get flowPercentage {
    if (_activities.isEmpty) return 0.0;
    return (flowActivities / _activities.length) * 100;
  }
}
