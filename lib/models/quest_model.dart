// lib/models/quest_model.dart

enum QuestType { breathing, flowChart, journal }
enum QuestStatus { locked, active, completed }

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int targetCount;
  int currentCount;
  QuestStatus status;
  final int rewardPoints;
  final DateTime date;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    this.currentCount = 0,
    this.status = QuestStatus.active,
    required this.rewardPoints,
    required this.date,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);

  void incrementProgress() {
    if (status == QuestStatus.active && !isCompleted) {
      currentCount++;
      if (isCompleted) {
        status = QuestStatus.completed;
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'status': status.name,
        'rewardPoints': rewardPoints,
        'date': date.toIso8601String(),
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: QuestType.values.firstWhere((e) => e.name == json['type']),
        targetCount: json['targetCount'],
        currentCount: json['currentCount'] ?? 0,
        status: QuestStatus.values.firstWhere((e) => e.name == json['status']),
        rewardPoints: json['rewardPoints'],
        date: DateTime.parse(json['date']),
      );
}