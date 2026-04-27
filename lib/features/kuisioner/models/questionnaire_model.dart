/// Model untuk data kuesioner.
/// Sesuai revisi dokumen kuesioner_ml_mapping.docx
///
/// Field dari Register (tidak ada di kuesioner lagi):
/// gender, region, education_level, daily_role, device_type, income_level
///
/// Field baru di kuesioner:
/// age (Q7) — diisi di kuesioner karena tidak ada di register
class QuestionnaireModel {
  final String? id;
  final String? userId;

  // ── Dari Register — dikirim ke Laravel tapi tidak ditanyakan di kuesioner ──
  final String incomeLevel; // Low / Lower-Mid / Upper-Mid / High
  final String
  dailyRole; // Student / Full-time / Part-time / Caregiver / Unemployed
  final String deviceType; // Android / iPhone / Laptop / Tablet
  final String gender; // Male / Female
  final String region; // Africa / Asia / Europe / Middle East / ...
  final String educationLevel; // High School / Bachelor / Master / PhD

  // ── Q7: Usia — input angka 13–50 ──────────────────────────────────────────
  final int age;

  // ── Q8–Q12: Pilihan → nilai ML (bukan slider lagi) ────────────────────────
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
    required this.incomeLevel,
    required this.dailyRole,
    required this.deviceType,
    required this.gender,
    required this.region,
    required this.educationLevel,
    required this.age,
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
  // Semua field dikirim ke Laravel POST /api/surveys
  // device_type tidak ada di fillable Questionnaire.php tapi
  // dikirim agar Laravel bisa simpan jika nanti ditambahkan
  Map<String, dynamic> toJson() {
    return {
      'income_level': incomeLevel,
      'daily_role': dailyRole,
      'gender': gender,
      'region': region,
      'education_level': educationLevel,
      'age': age,
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

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'],
      incomeLevel: json['income_level'] ?? 'Low',
      dailyRole: json['daily_role'] ?? 'Student',
      deviceType: json['device_type'] ?? 'Android',
      gender: json['gender'] ?? 'Male',
      region: json['region'] ?? 'Asia',
      educationLevel: json['education_level'] ?? 'High School',
      age: _toInt(json['age']),
      deviceHoursPerDay: _toDouble(json['device_hours_per_day']),
      phoneUnlocksPerDay: _toInt(json['phone_unlocks_per_day']),
      notificationsPerDay: _toInt(json['notifications_per_day']),
      socialMediaMinutes: _toInt(json['social_media_minutes']),
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
    return const QuestionnaireModel(
      incomeLevel: 'Low',
      dailyRole: 'Student',
      deviceType: 'Android',
      gender: 'Male',
      region: 'Asia',
      educationLevel: 'High School',
      age: 20,
      deviceHoursPerDay: 5.5, // default pilihan "Sedang"
      phoneUnlocksPerDay: 75, // default pilihan "Cukup sering"
      notificationsPerDay: 100, // default pilihan "Sedikit"
      socialMediaMinutes: 30, // default pilihan "<1 jam"
      studyMinutes: 150, // default pilihan "Cukup"
      physicalActivityDays: 3,
      sleepHours: 7.0,
      sleepQuality: 3.0, // default pilihan "Cukup"
      anxietyScore: 5.0,
      depressionScore: 5.0,
      stressLevel: 5.0,
      happinessScore: 5.0,
    );
  }

  // ── CopyWith ───────────────────────────────────────────────────────────────
  QuestionnaireModel copyWith({
    String? incomeLevel,
    String? dailyRole,
    String? deviceType,
    String? gender,
    String? region,
    String? educationLevel,
    int? age,
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
      incomeLevel: incomeLevel ?? this.incomeLevel,
      dailyRole: dailyRole ?? this.dailyRole,
      deviceType: deviceType ?? this.deviceType,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      educationLevel: educationLevel ?? this.educationLevel,
      age: age ?? this.age,
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
