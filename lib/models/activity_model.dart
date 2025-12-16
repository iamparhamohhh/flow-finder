import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 0)
class Activity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double skillLevel; // 0 تا 10

  @HiveField(3)
  double challengeLevel; // 0 تا 10

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  Activity({
    required this.id,
    required this.name,
    required this.skillLevel,
    required this.challengeLevel,
    required this.createdAt,
    this.updatedAt,
  });

  // محاسبه وضعیت فلو
  String get flowState {
    double diff = (challengeLevel - skillLevel).abs();

    if (diff <= 2) {
      return 'Flow'; // فلو
    } else if (challengeLevel > skillLevel) {
      if (diff <= 4) {
        return 'Arousal'; // برانگیختگی
      } else {
        return 'Anxiety'; // اضطراب
      }
    } else {
      if (diff <= 4) {
        return 'Boredom'; // کسالت
      } else {
        return 'Relaxation'; // آرامش
      }
    }
  }

  // رنگ دایره بر اساس وضعیت
  int get stateColor {
    switch (flowState) {
      case 'Flow':
        return 0xFF4CAF50; // سبز
      case 'Arousal':
        return 0xFF2196F3; // آبی
      case 'Anxiety':
        return 0xFFF44336; // قرمز
      case 'Boredom':
        return 0xFFFF9800; // نارنجی
      case 'Relaxation':
        return 0xFF9C27B0; // بنفش
      default:
        return 0xFF9E9E9E; // خاکستری
    }
  }

  // شدت لرزش (0 تا 1)
  double get vibrationIntensity {
      if (flowState == 'Flow') {
      return 0.1; // آرام
    } else if (flowState == 'Anxiety') {
      return 1.0; // شدید
    } else {
      return 0.5; // متوسط
    }
  }

  // Copy with
  Activity copyWith({
    String? id,
    String? name,
    double? skillLevel,
    double? challengeLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      skillLevel: skillLevel ?? this.skillLevel,
      challengeLevel: challengeLevel ?? this.challengeLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'skillLevel': skillLevel,
      'challengeLevel': challengeLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From Map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      skillLevel: map['skillLevel'],
      challengeLevel: map['challengeLevel'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}
