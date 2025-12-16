// lib/screens/quests/daily_quests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quest_provider.dart';
import '../../models/quest_model.dart';

class DailyQuestsScreen extends StatelessWidget {
  const DailyQuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quests'),
        centerTitle: true,
      ),
      body: Consumer<QuestProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // کارت آمار بالای صفحه
                _StatsCard(provider: provider),
                
                const SizedBox(height: 24),
                
                // عنوان Quest‌ها
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Quests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // لیست Quest‌ها
                ...provider.dailyQuests.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuestCard(quest: quest),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========== کارت آمار ==========
class _StatsCard extends StatelessWidget {
  final QuestProvider provider;

  const _StatsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.stars_rounded,
            label: 'Points',
            value: '${provider.totalPoints}',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${provider.currentStreak}',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _StatItem(
            icon: Icons.check_circle_rounded,
            label: 'Today',
            value: '${provider.completedTodayCount}/${provider.dailyQuests.length}',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

// ========== کارت هر Quest ==========
class _QuestCard extends StatelessWidget {
  final DailyQuest quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green.shade300 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // آیکون Quest
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getQuestColor(quest.type).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getQuestIcon(quest.type),
              color: _getQuestColor(quest.type),
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // عنوان و توضیحات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : Colors.black87,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: quest.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : _getQuestColor(quest.type),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // نقاط پاداش
          Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.stars_rounded,
                color: isCompleted ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '+${quest.rewardPoints}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.breathing:
        return Icons.air_rounded;
      case QuestType.flowChart:
        return Icons.auto_graph_rounded;
      case QuestType.journal:
        return Icons.book_rounded;
    }
  }

  Color _getQuestColor(QuestType type) {
    switch (type) {
      case QuestType.breathing:
        return Colors.blue;
      case QuestType.flowChart:
        return Colors.purple;
      case QuestType.journal:
        return Colors.teal;
    }
  }
}