// lib/models/live_session_model.dart

import 'user_model.dart';

enum SessionType { breathing, meditation, bodyScan, pmr, yoga, discussion }

enum SessionStatus { scheduled, live, ended, cancelled }

class LiveSession {
  final String id;
  final String title;
  final String description;
  final SessionType type;
  final DateTime scheduledStart;
  final int durationMinutes;
  final String hostId;
  final UserModel? host;
  final int maxParticipants;
  final int currentParticipants;
  final SessionStatus status;
  final List<String> participantIds;
  final String? streamUrl;
  final String? thumbnailUrl;
  final bool isRecorded;
  final List<String> tags;

  LiveSession({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.scheduledStart,
    required this.durationMinutes,
    required this.hostId,
    this.host,
    this.maxParticipants = 50,
    this.currentParticipants = 0,
    this.status = SessionStatus.scheduled,
    this.participantIds = const [],
    this.streamUrl,
    this.thumbnailUrl,
    this.isRecorded = false,
    this.tags = const [],
  });

  bool get isFull => currentParticipants >= maxParticipants;
  bool get isLive => status == SessionStatus.live;
  bool get canJoin =>
      !isFull &&
      (status == SessionStatus.scheduled || status == SessionStatus.live);

  DateTime get estimatedEnd =>
      scheduledStart.add(Duration(minutes: durationMinutes));
  Duration get timeUntilStart => scheduledStart.difference(DateTime.now());
  bool get isStartingSoon =>
      timeUntilStart.inMinutes <= 5 && timeUntilStart.inMinutes > 0;

  String get sessionTypeLabel {
    switch (type) {
      case SessionType.breathing:
        return '🌬️ Breathing';
      case SessionType.meditation:
        return '🧘 Meditation';
      case SessionType.bodyScan:
        return '💆 Body Scan';
      case SessionType.pmr:
        return '💪 PMR';
      case SessionType.yoga:
        return '🤸 Yoga';
      case SessionType.discussion:
        return '💬 Discussion';
    }
  }

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.meditation,
      ),
      scheduledStart: DateTime.parse(json['scheduledStart']),
      durationMinutes: json['durationMinutes'],
      hostId: json['hostId'],
      host: json['host'] != null ? UserModel.fromJson(json['host']) : null,
      maxParticipants: json['maxParticipants'] ?? 50,
      currentParticipants: json['currentParticipants'] ?? 0,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      participantIds: List<String>.from(json['participantIds'] ?? []),
      streamUrl: json['streamUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      isRecorded: json['isRecorded'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'scheduledStart': scheduledStart.toIso8601String(),
      'durationMinutes': durationMinutes,
      'hostId': hostId,
      'host': host?.toJson(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'status': status.name,
      'participantIds': participantIds,
      'streamUrl': streamUrl,
      'thumbnailUrl': thumbnailUrl,
      'isRecorded': isRecorded,
      'tags': tags,
    };
  }

  LiveSession copyWith({
    SessionStatus? status,
    int? currentParticipants,
    List<String>? participantIds,
    String? streamUrl,
  }) {
    return LiveSession(
      id: id,
      title: title,
      description: description,
      type: type,
      scheduledStart: scheduledStart,
      durationMinutes: durationMinutes,
      hostId: hostId,
      host: host,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnailUrl: thumbnailUrl,
      isRecorded: isRecorded,
      tags: tags,
    );
  }
}

class SessionParticipant {
  final String userId;
  final UserModel user;
  final DateTime joinedAt;
  final bool isMuted;
  final bool isVideoOn;

  SessionParticipant({
    required this.userId,
    required this.user,
    required this.joinedAt,
    this.isMuted = false,
    this.isVideoOn = false,
  });

  factory SessionParticipant.fromJson(Map<String, dynamic> json) {
    return SessionParticipant(
      userId: json['userId'],
      user: UserModel.fromJson(json['user']),
      joinedAt: DateTime.parse(json['joinedAt']),
      isMuted: json['isMuted'] ?? false,
      isVideoOn: json['isVideoOn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'user': user.toJson(),
      'joinedAt': joinedAt.toIso8601String(),
      'isMuted': isMuted,
      'isVideoOn': isVideoOn,
    };
  }
}
