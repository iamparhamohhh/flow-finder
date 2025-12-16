// ⚠️ START: Updated home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flow_chart_screen.dart';
import 'practices/practices_main_screen.dart'; // ⚠️ تغییر: ایمپورت جدید
import '../providers/quest_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FlowChartScreen(),
    const PracticesMainScreen(), // ⚠️ تغییر: از BreathingScreen به PracticesMainScreen
    const Placeholder(), // Journal (فعلاً خالی)
    const Placeholder(), // Dashboard (فعلاً خالی)
  ];

  @override
  void initState() {
    super.initState();

    // ریست روزانه Quest ها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuestProvider>().checkAndResetDaily();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'نمودار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'تمرین',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'ژورنال'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
        ],
      ),
    );
  }
}

// ⚠️ END: Updated home_screen.dart
