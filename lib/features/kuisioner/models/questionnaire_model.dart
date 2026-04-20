/// Model untuk data kuesioner.
/// Sesuai dengan collection `questionnaires` di MongoDB.
class QuestionnaireModel {
  final String? id;
  final String? userId;
  final String incomeLevel;
  final String dailyRole;
  final String deviceType;
  final double deviceHoursPerDay;
  final int phoneUnlocksPerDay;
  final int notificationsPerDay;
  final int socialMediaMinutes;
  final int studyMinutes;
  final int physicalActivityDays;
  final double sleepHours;
  final int sleepQuality;
  final int anxietyScore;
  final int depressionScore;
  final int stressLevel;
  final int happinessScore;
  final DateTime? createdAt;

  const QuestionnaireModel({
    this.id,
    this.userId,
    required this.incomeLevel,
    required this.dailyRole,
    required this.deviceType,
    required this.deviceHoursPerDay,
    required this.phoneUnlocksPerDay,
    required this.notificationsPerDay,
    required this.socialMediaMinutes,
    required this.studyMinutes,
    required this.physicalActivityDays,
    required this.sleepHours,
    required this.sleepQuality,
    required this.anxietyScore,
    required this.depressionScore,
    required this.stressLevel,
    required this.happinessScore,
    this.createdAt,
  });

  // ── To JSON (kirim ke Laravel) ─────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'income_level': incomeLevel,
      'daily_role': dailyRole,
      'device_type': deviceType,
      'device_hours_per_day': deviceHoursPerDay,
      'phone_unlocks_per_day': phoneUnlocksPerDay,
      'notifications_per_day': notificationsPerDay,
      'social_media_minutes': socialMediaMinutes,
      'study_minutes': studyMinutes,
      'physical_activity_days': physicalActivityDays,
      'sleep_hours': sleepHours,
      'sleep_quality': sleepQuality,
      'anxiety_score': anxietyScore,
      'depression_score': depressionScore,
      'stress_level': stressLevel,
      'happiness_score': happinessScore,
    };
  }

  // ── From JSON (dari response Laravel) ─────────────────────────────────────
  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'],
      incomeLevel: json['income_level'] ?? '',
      dailyRole: json['daily_role'] ?? '',
      deviceType: json['device_type'] ?? 'Smartphone',
      deviceHoursPerDay: (json['device_hours_per_day'] ?? 0).toDouble(),
      phoneUnlocksPerDay: (json['phone_unlocks_per_day'] ?? 0) as int,
      notificationsPerDay: (json['notifications_per_day'] ?? 0) as int,
      socialMediaMinutes: (json['social_media_minutes'] ?? 0) as int,
      studyMinutes: (json['study_minutes'] ?? 0) as int,
      physicalActivityDays: (json['physical_activity_days'] ?? 0) as int,
      sleepHours: (json['sleep_hours'] ?? 0).toDouble(),
      sleepQuality: (json['sleep_quality'] ?? 0) as int,
      anxietyScore: (json['anxiety_score'] ?? 0) as int,
      depressionScore: (json['depression_score'] ?? 0) as int,
      stressLevel: (json['stress_level'] ?? 0) as int,
      happinessScore: (json['happiness_score'] ?? 0) as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // ── Empty (default kosong untuk form) ─────────────────────────────────────
  factory QuestionnaireModel.empty() {
    return const QuestionnaireModel(
      incomeLevel: 'Middle',
      dailyRole: 'Student',
      deviceType: 'Smartphone',
      deviceHoursPerDay: 5.0,
      phoneUnlocksPerDay: 50,
      notificationsPerDay: 100,
      socialMediaMinutes: 60,
      studyMinutes: 60,
      physicalActivityDays: 3,
      sleepHours: 7.0,
      sleepQuality: 5,
      anxietyScore: 5,
      depressionScore: 5,
      stressLevel: 5,
      happinessScore: 5,
    );
  }

  QuestionnaireModel copyWith({
    String? incomeLevel,
    String? dailyRole,
    String? deviceType,
    double? deviceHoursPerDay,
    int? phoneUnlocksPerDay,
    int? notificationsPerDay,
    int? socialMediaMinutes,
    int? studyMinutes,
    int? physicalActivityDays,
    double? sleepHours,
    int? sleepQuality,
    int? anxietyScore,
    int? depressionScore,
    int? stressLevel,
    int? happinessScore,
  }) {
    return QuestionnaireModel(
      id: id,
      userId: userId,
      incomeLevel: incomeLevel ?? this.incomeLevel,
      dailyRole: dailyRole ?? this.dailyRole,
      deviceType: deviceType ?? this.deviceType,
      deviceHoursPerDay: deviceHoursPerDay ?? this.deviceHoursPerDay,
      phoneUnlocksPerDay: phoneUnlocksPerDay ?? this.phoneUnlocksPerDay,
      notificationsPerDay: notificationsPerDay ?? this.notificationsPerDay,
      socialMediaMinutes: socialMediaMinutes ?? this.socialMediaMinutes,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      physicalActivityDays: physicalActivityDays ?? this.physicalActivityDays,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      anxietyScore: anxietyScore ?? this.anxietyScore,
      depressionScore: depressionScore ?? this.depressionScore,
      stressLevel: stressLevel ?? this.stressLevel,
      happinessScore: happinessScore ?? this.happinessScore,
    );
  }
}
