import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';

class HiveService {
  // نام Box ها
  static const String activitiesBox = 'activities';
  static const String journalBox = 'journal';
  static const String practicesBox = 'practices';
  static const String questsBox = 'quests';
  static const String settingsBox = 'settings';

  // راه‌اندازی اولیه Hive
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(ActivityAdapter());
    
    // باز کردن Box های مورد نیاز
    await openBoxes();
  }

  // باز کردن تمام Box ها
  static Future<void> openBoxes() async {
    await Hive.openBox<Activity>(activitiesBox);
    await Hive.openBox(journalBox);
    await Hive.openBox(practicesBox);
    await Hive.openBox(questsBox);
    await Hive.openBox(settingsBox);
  }

  // بستن تمام Box ها
  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  // پاک کردن تمام داده‌ها (برای تست)
  static Future<void> clearAll() async {
    await Hive.box(activitiesBox).clear();
    await Hive.box(journalBox).clear();
    await Hive.box(practicesBox).clear();
    await Hive.box(questsBox).clear();
    await Hive.box(settingsBox).clear();
  }
}
