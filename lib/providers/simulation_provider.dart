import 'package:flutter/material.dart';

enum MentalState {
  flow,
  arousal,
  boredom,
  anxiety,
  relaxation,
}

class MentalStateInfo {
  final MentalState state;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const MentalStateInfo({
    required this.state,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class SimulationProvider extends ChangeNotifier {
  double _skill = 5.0;
  double _challenge = 5.0;

  double get skill => _skill;
  double get challenge => _challenge;

  void setSkill(double value) {
    _skill = value;
    notifyListeners();
  }

  void setChallenge(double value) {
    _challenge = value;
    notifyListeners();
  }

  MentalState getCurrentState() {
    final difference = _challenge - _skill;

    if (difference.abs() <= 2) {
      return MentalState.flow;
    } else if (difference > 2 && difference <= 4) {
      return MentalState.arousal;
    } else if (difference > 4) {
      return MentalState.anxiety;
    } else if (difference < -2 && difference >= -4) {
      return MentalState.boredom;
    } else {
      return MentalState.relaxation;
    }
  }

  MentalStateInfo getStateInfo() {
    final state = getCurrentState();

    switch (state) {
      case MentalState.flow:
        return MentalStateInfo(
          state: state,
          title: 'Flow',
          description:
              'A perfect balance. You feel fully immersed and energized.',
          color: const Color(0xFF4CAF50),
          icon: Icons.water_drop_rounded,
        );

      case MentalState.arousal:
        return MentalStateInfo(
          state: state,
          title: 'Arousal',
          description:
              'The challenge is slightly higher. You feel excited and alert.',
          color: const Color(0xFFFF9800),
          icon: Icons.arrow_upward_rounded,
        );

      case MentalState.boredom:
        return MentalStateInfo(
          state: state,
          title: 'Boredom',
          description: 'Your skill is higher. You need more challenge.',
          color: const Color(0xFF9E9E9E),
          icon: Icons.sentiment_dissatisfied_rounded,
        );

      case MentalState.anxiety:
        return MentalStateInfo(
          state: state,
          title: 'Anxiety',
          description:
              'The challenge is much higher. You might feel overwhelmed.',
          color: const Color(0xFFF44336),
          icon: Icons.warning_rounded,
        );

      case MentalState.relaxation:
        return MentalStateInfo(
          state: state,
          title: 'Relaxation',
          description: 'Your skill is much higher. You feel calm and in control.',
          color: const Color(0xFF2196F3),
          icon: Icons.self_improvement_rounded,
        );
    }
  }
}
