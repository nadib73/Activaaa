//lib/features/kuisioner/models/questionnaire_model.dart

import 'package:flutter/foundation.dart';

/// Model untuk data kuesioner.
/// Sesuai revisi schema v2 — income_level/daily_role/age pindah ke User.
///
/// Field di kuesioner:
/// device_type (auto-detect dari Flutter), + semua field survey
class QuestionnaireModel {
  final String? id;
  final String? userId;

  // ── Device type — auto-detect dari Flutter ─────────────────────────────────
  final String deviceType; // Android / iPhone

  // ── Q8–Q12: Pilihan → nilai ML ─────────────────────────────────────────────
  final double deviceHoursPerDay; // Q8:  1.5/3/5.5/8.5/12
  final int phoneUnlocksPerDay; // Q9:  10/35/75/150/250
  final int notificationsPerDay; // Q10: 30/100/300/700/1100
  final int socialMediaMinutes; // Q11: 0/30/120/240/400
  final int studyMinutes; // Q12: 10/60/150/300/400

  // ── Q13–Q14: Slider ───────────────────────────────────────────────────────
  final int physicalActivityDays; // Q13: 0–7 hari
  final double sleepHours; // Q14: 3–11 jam

  // ── Q15: Pilihan → nilai ML ───────────────────────────────────────────────
  final double sleepQuality; // Q15: 1/2/3/4/5

  // ── Q16–Q19: Skala ────────────────────────────────────────────────────────
  final double anxietyScore; // Q16: 0–27
  final double depressionScore; // Q17: 0–27
  final double stressLevel; // Q18: 1–10
  final double happinessScore; // Q19: 0–10

  final DateTime? createdAt;

  const QuestionnaireModel({
    this.id,
    this.userId,
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

  // ── To JSON ────────────────────────────────────────────────────────────────
  // Dikirim ke Laravel POST /api/surveys
  Map<String, dynamic> toJson() {
    return {
      'device_type': deviceType,
      'device_hours_per_day': deviceHoursPerDay,
      'phone_unlocks': phoneUnlocksPerDay,
      'notifications_per_day': notificationsPerDay,
      'social_media_mins': socialMediaMinutes,
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

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'],
      deviceType: json['device_type'] ?? 'Laptop',
      deviceHoursPerDay: _toDouble(json['device_hours_per_day']),
      phoneUnlocksPerDay: _toInt(json['phone_unlocks']),
      notificationsPerDay: _toInt(json['notifications_per_day']),
      socialMediaMinutes: _toInt(json['social_media_mins']),
      studyMinutes: _toInt(json['study_minutes']),
      physicalActivityDays: _toInt(json['physical_activity_days']),
      sleepHours: _toDouble(json['sleep_hours']),
      sleepQuality: _toDouble(json['sleep_quality']),
      anxietyScore: _toDouble(json['anxiety_score']),
      depressionScore: _toDouble(json['depression_score']),
      stressLevel: _toDouble(json['stress_level']),
      happinessScore: _toDouble(json['happiness_score']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  factory QuestionnaireModel.empty() {
    return QuestionnaireModel(
      deviceType: kIsWeb
          ? 'Web'
          : defaultTargetPlatform == TargetPlatform.android
              ? 'Android'
              : 'iPhone',
      deviceHoursPerDay: 0.0,
      phoneUnlocksPerDay: 0,
      notificationsPerDay: 0,
      socialMediaMinutes: -1, // Agar tidak bentrok dengan pilihan "Tidak Pakai" (0)
      studyMinutes: 0,
      physicalActivityDays: 0,
      sleepHours: 7.0, // Default tengah untuk slider
      sleepQuality: 0.0,
      anxietyScore: -1.0,
      depressionScore: -1.0,
      stressLevel: -1.0, 
      happinessScore: -1.0, 
    );
  }

  // ── CopyWith ───────────────────────────────────────────────────────────────
  QuestionnaireModel copyWith({
    String? deviceType,
    double? deviceHoursPerDay,
    int? phoneUnlocksPerDay,
    int? notificationsPerDay,
    int? socialMediaMinutes,
    int? studyMinutes,
    int? physicalActivityDays,
    double? sleepHours,
    double? sleepQuality,
    double? anxietyScore,
    double? depressionScore,
    double? stressLevel,
    double? happinessScore,
  }) {
    return QuestionnaireModel(
      id: id,
      userId: userId,
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

  // ── Validation ─────────────────────────────────────────────────────────────
  bool get isPage1Complete =>
      deviceHoursPerDay > 0 &&
      phoneUnlocksPerDay > 0 &&
      notificationsPerDay > 0 &&
      socialMediaMinutes >= 0 &&
      studyMinutes > 0;

  bool get isPage2Complete => sleepQuality > 0;

  bool get isPage3Complete =>
      anxietyScore >= 0 &&
      depressionScore >= 0 &&
      stressLevel >= 0 &&
      happinessScore >= 0;

  bool get isComplete => isPage1Complete && isPage2Complete && isPage3Complete;
}
