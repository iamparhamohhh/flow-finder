// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/activity_model.dart';
import 'providers/activity_provider.dart';
import 'providers/simulation_provider.dart';
import 'providers/breathing_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/social_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/live_session_provider.dart';
import 'providers/personalization_provider.dart';
import 'providers/tracking_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ActivityAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ⚠️ اول: QuestProvider
        ChangeNotifierProvider(create: (_) => QuestProvider()),

        // ⚠️ دوم: ActivityProvider با اتصال به QuestProvider
        ChangeNotifierProxyProvider<QuestProvider, ActivityProvider>(
          create: (context) => ActivityProvider()..init(),
          update: (context, questProvider, activityProvider) {
            activityProvider!.setQuestProvider(questProvider);
            return activityProvider;
          },
        ),

        // بقیه Providerها
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
        ChangeNotifierProvider(create: (_) => BreathingProvider()),

        // Social Features Providers
        ChangeNotifierProvider(create: (_) => SocialProvider()..init()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()..init()),
        ChangeNotifierProvider(create: (_) => LiveSessionProvider()..init()),

        // Personalization Provider
        ChangeNotifierProvider(
          create: (_) => PersonalizationProvider()..init(),
        ),

        // Tracking & Analytics Providers
        ChangeNotifierProvider(create: (_) => TrackingProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider()..initialize(),
        ),

        // Smart Notifications & Reminders Provider
        ChangeNotifierProvider(create: (_) => NotificationProvider()..init()),
      ],
      child: Consumer<PersonalizationProvider>(
        builder: (context, personalizationProvider, child) {
          return MaterialApp(
            title: 'Flow Finder',
            debugShowCheckedModeBanner: false,
            theme: personalizationProvider.themeData,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
