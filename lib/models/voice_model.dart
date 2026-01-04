// lib/models/voice_model.dart

enum VoiceGender { male, female, neutral }

enum VoiceLanguage { english, spanish, french, german, japanese, chinese }

class VoiceOption {
  final String id;
  final String name;
  final String description;
  final VoiceGender gender;
  final VoiceLanguage language;
  final String accent;
  final double pitch; // 0.5 - 2.0
  final double speed; // 0.5 - 2.0
  final bool isPremium;
  final String? sampleAudioUrl;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.description,
    required this.gender,
    required this.language,
    required this.accent,
    this.pitch = 1.0,
    this.speed = 1.0,
    this.isPremium = false,
    this.sampleAudioUrl,
  });

  String get displayName => '$name ($accent)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gender': gender.name,
      'language': language.name,
      'accent': accent,
      'pitch': pitch,
      'speed': speed,
      'isPremium': isPremium,
      'sampleAudioUrl': sampleAudioUrl,
    };
  }

  factory VoiceOption.fromJson(Map<String, dynamic> json) {
    return VoiceOption(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      gender: VoiceGender.values.firstWhere((e) => e.name == json['gender']),
      language: VoiceLanguage.values.firstWhere(
        (e) => e.name == json['language'],
      ),
      accent: json['accent'],
      pitch: json['pitch'] ?? 1.0,
      speed: json['speed'] ?? 1.0,
      isPremium: json['isPremium'] ?? false,
      sampleAudioUrl: json['sampleAudioUrl'],
    );
  }

  static List<VoiceOption> getDefaultVoices() {
    return [
      const VoiceOption(
        id: 'voice_sarah',
        name: 'Sarah',
        description: 'Warm and calming female voice',
        gender: VoiceGender.female,
        language: VoiceLanguage.english,
        accent: 'US',
        pitch: 1.0,
        speed: 0.9,
      ),
      const VoiceOption(
        id: 'voice_michael',
        name: 'Michael',
        description: 'Deep and soothing male voice',
        gender: VoiceGender.male,
        language: VoiceLanguage.english,
        accent: 'US',
        pitch: 0.8,
        speed: 0.85,
      ),
      const VoiceOption(
        id: 'voice_emma',
        name: 'Emma',
        description: 'Gentle and peaceful female voice',
        gender: VoiceGender.female,
        language: VoiceLanguage.english,
        accent: 'UK',
        pitch: 1.1,
        speed: 0.9,
      ),
      const VoiceOption(
        id: 'voice_james',
        name: 'James',
        description: 'Confident and reassuring male voice',
        gender: VoiceGender.male,
        language: VoiceLanguage.english,
        accent: 'UK',
        pitch: 0.9,
        speed: 1.0,
      ),
      const VoiceOption(
        id: 'voice_alex',
        name: 'Alex',
        description: 'Balanced and neutral voice',
        gender: VoiceGender.neutral,
        language: VoiceLanguage.english,
        accent: 'Neutral',
        pitch: 1.0,
        speed: 1.0,
      ),
      const VoiceOption(
        id: 'voice_sofia',
        name: 'Sofia',
        description: 'Melodic Spanish voice',
        gender: VoiceGender.female,
        language: VoiceLanguage.spanish,
        accent: 'Spain',
        pitch: 1.05,
        speed: 0.9,
        isPremium: true,
      ),
      const VoiceOption(
        id: 'voice_yuki',
        name: 'Yuki',
        description: 'Serene Japanese voice',
        gender: VoiceGender.female,
        language: VoiceLanguage.japanese,
        accent: 'Tokyo',
        pitch: 1.15,
        speed: 0.85,
        isPremium: true,
      ),
    ];
  }
}
