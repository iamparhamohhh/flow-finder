// lib/providers/quest_provider.dart

import 'package:flutter/material.dart';
import '../models/quest_model.dart';

class QuestProvider with ChangeNotifier {
  List<DailyQuest> _dailyQuests = [];
  int _totalPoints = 0;
  int _currentStreak = 0;

  List<DailyQuest> get dailyQuests => _dailyQuests;
  int get totalPoints => _totalPoints;
  int get currentStreak => _currentStreak;
  int get completedTodayCount =>
      _dailyQuests.where((q) => q.isCompleted).length;

  QuestProvider() {
    _initializeDailyQuests();
  }

  void _initializeDailyQuests() {
    final today = DateTime.now();
    
    _dailyQuests = [
      DailyQuest(
        id: 'breathing_${today.day}',
        title: 'Morning Breath',
        description: 'Complete 1 breathing exercise',
        type: QuestType.breathing,
        targetCount: 1,
        rewardPoints: 10,
        date: today,
      ),
      DailyQuest(
        id: 'flow_${today.day}',
        title: 'Track Your Flow',
        description: 'Add 1 activity to Flow Chart',
        type: QuestType.flowChart,
        targetCount: 1,
        rewardPoints: 10,
        date: today,
      ),
      DailyQuest(
        id: 'journal_${today.day}',
        title: 'Daily Reflection',
        description: 'Write 1 journal entry',
        type: QuestType.journal,
        targetCount: 1,
        rewardPoints: 15,
        date: today,
      ),
    ];
    
    notifyListeners();
  }

  // متد برای به‌روزرسانی Quest بعد از انجام فعالیت
  void updateQuestProgress(QuestType type) {
    for (var quest in _dailyQuests) {
      if (quest.type == type && !quest.isCompleted) {
        quest.incrementProgress();
        
        if (quest.isCompleted) {
          _totalPoints += quest.rewardPoints;
          _checkStreakUpdate();
        }
        
        notifyListeners();
        return;
      }
    }
  }

  void _checkStreakUpdate() {
    if (completedTodayCount == _dailyQuests.length) {
      _currentStreak++;
      notifyListeners();
    }
  }

  // بررسی و ریست Quest‌های روزانه
  void checkAndResetDaily() {
    final today = DateTime.now();
    final questDate = _dailyQuests.isNotEmpty ? _dailyQuests.first.date : null;
    
    if (questDate != null && !_isSameDay(questDate, today)) {
      // اگر Quest‌های دیروز کامل نشدن، streak صفر میشه
      if (completedTodayCount < _dailyQuests.length) {
        _currentStreak = 0;
      }
      
      _initializeDailyQuests();
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}