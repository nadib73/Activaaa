/// Model untuk data analytics / insight.
class AnalyticsModel {
  final String period;
  final double avgDependenceScore;
  final double dependenceChangePercentage;
  final String dependenceChangeLabel;
  final int highRiskDays;
  final int totalSurveysWeek;
  final List<DailyTrend> dailyTrend;

  // ── Tambahan untuk Laporan Perkembangan ──
  final double screenTimeHours;
  final double screenTimeChange;
  final int socialMediaMins;
  final double socialMediaChangePercentage;
  final double sleepHours;
  final double sleepHoursChange;
  final int sleepQuality;
  final int sleepQualityPrev;
  final double stressLevel;
  final double stressLevelChangePercentage;
  
  final List<String> causes;
  final List<String> recommendations;
  
  final double thisWeekAvgScore;
  final double lastWeekAvgScore;

  // ── Tambahan untuk Donut Chart (Grafik) ──
  final int countLow;
  final int countMedium;
  final int countHigh;

  const AnalyticsModel({
    required this.period,
    required this.avgDependenceScore,
    required this.dependenceChangePercentage,
    required this.dependenceChangeLabel,
    required this.highRiskDays,
    required this.totalSurveysWeek,
    required this.dailyTrend,
    this.screenTimeHours = 0,
    this.screenTimeChange = 0,
    this.socialMediaMins = 0,
    this.socialMediaChangePercentage = 0,
    this.sleepHours = 0,
    this.sleepHoursChange = 0,
    this.sleepQuality = 0,
    this.sleepQualityPrev = 0,
    this.stressLevel = 0,
    this.stressLevelChangePercentage = 0,
    this.causes = const [],
    this.recommendations = const [],
    this.thisWeekAvgScore = 0,
    this.lastWeekAvgScore = 0,
    this.countLow = 0,
    this.countMedium = 0,
    this.countHigh = 0,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawTrend = json['daily_trend'] as List? ?? [];
    return AnalyticsModel(
      period: json['period']?.toString() ?? '7 hari terakhir',
      avgDependenceScore: _toDouble(json['avg_dependence_score']),
      dependenceChangePercentage: _toDouble(json['dependence_change_percentage']),
      dependenceChangeLabel: json['dependence_change_label']?.toString() ?? '',
      highRiskDays: _toInt(json['high_risk_days']),
      totalSurveysWeek: _toInt(json['total_surveys_week']),
      dailyTrend: rawTrend
          .map((e) => DailyTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      screenTimeHours: _toDouble(json['screen_time_hours']),
      screenTimeChange: _toDouble(json['screen_time_change']),
      socialMediaMins: _toInt(json['social_media_mins']),
      socialMediaChangePercentage: _toDouble(json['social_media_change_percentage']),
      sleepHours: _toDouble(json['sleep_hours']),
      sleepHoursChange: _toDouble(json['sleep_hours_change']),
      sleepQuality: _toInt(json['sleep_quality']),
      sleepQualityPrev: _toInt(json['sleep_quality_prev']),
      stressLevel: _toDouble(json['stress_level']),
      stressLevelChangePercentage: _toDouble(json['stress_level_change_percentage']),
      causes: (json['causes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      recommendations: (json['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thisWeekAvgScore: _toDouble(json['this_week_avg_score']),
      lastWeekAvgScore: _toDouble(json['last_week_avg_score']),
      countLow: _toInt(json['count_low']),
      countMedium: _toInt(json['count_medium']),
      countHigh: _toInt(json['count_high']),
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

  factory AnalyticsModel.mock() {
    final trends = [
      DailyTrend(date: '2025-04-01', dependenceScore: 55, deviceHours: 8.5, socialMediaMins: 180, sleepHours: 7.0, category: 'rendah', confidence: 0.8),
      DailyTrend(date: '2025-04-02', dependenceScore: 58, deviceHours: 9.0, socialMediaMins: 210, sleepHours: 6.5, category: 'sedang', confidence: 0.8),
      DailyTrend(date: '2025-04-03', dependenceScore: 62, deviceHours: 10.5, socialMediaMins: 300, sleepHours: 5.5, category: 'sedang', confidence: 0.8),
      DailyTrend(date: '2025-04-04', dependenceScore: 57, deviceHours: 8.0, socialMediaMins: 150, sleepHours: 7.5, category: 'rendah', confidence: 0.8),
      DailyTrend(date: '2025-04-05', dependenceScore: 65, deviceHours: 11.0, socialMediaMins: 350, sleepHours: 6.0, category: 'tinggi', confidence: 0.8),
      DailyTrend(date: '2025-04-06', dependenceScore: 60, deviceHours: 9.5, socialMediaMins: 240, sleepHours: 6.8, category: 'sedang', confidence: 0.8),
      DailyTrend(date: '2025-04-07', dependenceScore: 63, deviceHours: 10.0, socialMediaMins: 280, sleepHours: 6.2, category: 'sedang', confidence: 0.8),
    ];

    return AnalyticsModel(
      period: '7 hari terakhir',
      avgDependenceScore: 60.0,
      dependenceChangePercentage: 12.0,
      dependenceChangeLabel: 'Memburuk',
      highRiskDays: 2,
      totalSurveysWeek: 14,
      dailyTrend: trends,
      screenTimeHours: 9.3,
      screenTimeChange: 1.5,
      socialMediaMins: 244,
      socialMediaChangePercentage: 15.0,
      sleepHours: 6.5,
      sleepHoursChange: -0.8,
      sleepQuality: 3,
      sleepQualityPrev: 4,
      stressLevel: 7.2,
      stressLevelChangePercentage: 8.0,
      causes: ['Scroll media sosial berlebihan', 'Kurang olahraga', 'Tidur larut malam'],
      recommendations: ['Batasi sosmed 2 jam/hari', 'Olahraga pagi 20 menit', 'Tidur sebelum jam 11 malam'],
      thisWeekAvgScore: 60.0,
      lastWeekAvgScore: 54.0,
      countLow: 2,
      countMedium: 4,
      countHigh: 1,
    );
  }

  int get avgDependenceInt => avgDependenceScore.round().clamp(0, 100);

  String get insightText {
    final absVal = dependenceChangePercentage.abs().toStringAsFixed(0);
    if (totalSurveysWeek == 0) return 'Isi kuesioner untuk melihat insight pertamamu.';
    if (dependenceChangePercentage < 0) {
      return 'Kondisi kamu membaik $absVal% dibanding minggu lalu';
    } else if (dependenceChangePercentage > 0) {
      return 'Ketergantungan digital kamu meningkat $absVal% dalam 7 hari terakhir';
    }
    return 'Ketergantungan digital kamu stabil dibanding minggu lalu';
  }

  String get dependenceInsight => insightText;

  String get dependenceChangeLabelFormatted {
    final sign = dependenceChangePercentage >= 0 ? '+' : '';
    return '$sign${dependenceChangePercentage.toStringAsFixed(0)}%';
  }

  String get screenTimeInsight {
    final absVal = screenTimeChange.abs().toStringAsFixed(1);
    if (screenTimeChange > 0) {
      return 'Waktu penggunaan device kamu naik $absVal jam/hari';
    } else if (screenTimeChange < 0) {
      return 'Screen time turun $absVal jam/hari (lebih sehat 👍)';
    }
    return 'Waktu penggunaan device kamu stabil';
  }

  String get socialMediaInsight {
    final absVal = socialMediaChangePercentage.abs().toStringAsFixed(0);
    if (socialMediaChangePercentage > 0) {
      return 'Penggunaan media sosial meningkat $absVal%';
    } else if (socialMediaChangePercentage < 0) {
      return 'Kamu lebih jarang membuka media sosial minggu ini';
    }
    return 'Penggunaan media sosial kamu stabil';
  }

  String get sleepInsight {
    final hoursAbs = sleepHoursChange.abs().toStringAsFixed(1);
    if (sleepHoursChange < 0) {
      return 'Waktu tidur kamu berkurang $hoursAbs jam';
    } else if (sleepHoursChange > 0) {
      return 'Waktu tidur kamu bertambah $hoursAbs jam';
    }
    
    if (sleepQuality < sleepQualityPrev) {
      return 'Kualitas tidur menurun (dari $sleepQualityPrev → $sleepQuality)';
    } else if (sleepQuality > sleepQualityPrev) {
      return 'Kualitas tidur membaik (dari $sleepQualityPrev → $sleepQuality)';
    }
    
    return 'Durasi dan kualitas tidur kamu stabil';
  }

  String get stressInsight {
    final absVal = stressLevelChangePercentage.abs().toStringAsFixed(0);
    if (stressLevelChangePercentage > 0) {
      return 'Tingkat stres meningkat $absVal%';
    } else if (stressLevelChangePercentage < 0) {
      return 'Stres kamu menurun $absVal% (lebih rileks)';
    }
    return 'Stres kamu lebih stabil dibanding minggu lalu';
  }
}

class DailyTrend {
  final String date;
  final double dependenceScore;
  final double deviceHours;
  final int socialMediaMins;
  final double sleepHours;
  final String category;
  final double confidence;

  const DailyTrend({
    required this.date,
    required this.dependenceScore,
    this.deviceHours = 0,
    this.socialMediaMins = 0,
    this.sleepHours = 0,
    required this.category,
    required this.confidence,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      date: json['date']?.toString() ?? '',
      dependenceScore: _toDouble(json['dependence_score']),
      deviceHours: _toDouble(json['device_hours']),
      socialMediaMins: _toInt(json['social_media_mins']),
      sleepHours: _toDouble(json['sleep_hours']),
      category: json['category']?.toString() ?? 'rendah',
      confidence: _toDouble(json['confidence']),
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

  String get shortDate {
    try {
      final p = date.split('-');
      return '${p[2]}/${p[1]}';
    } catch (_) {
      return date;
    }
  }
}

class ChartPoint {
  final String label;
  final double value;
  const ChartPoint({required this.label, required this.value});
}
