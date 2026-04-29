/// Model untuk data analytics / insight.
///
/// Sesuai response baru AnalyticsController@insight():
/// { period, avg_dependence_score, dependence_change_percentage,
///   dependence_change_label, high_risk_days, total_surveys_week, daily_trend }
class AnalyticsModel {
  final String period;
  final double avgDependenceScore;
  final double dependenceChangePercentage;
  final String dependenceChangeLabel;
  final int highRiskDays;
  final int totalSurveysWeek;
  final List<DailyTrend> dailyTrend;

  const AnalyticsModel({
    required this.period,
    required this.avgDependenceScore,
    required this.dependenceChangePercentage,
    required this.dependenceChangeLabel,
    required this.highRiskDays,
    required this.totalSurveysWeek,
    required this.dailyTrend,
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
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

  // ── Mock ───────────────────────────────────────────────────────────────────
  factory AnalyticsModel.mock() {
    return AnalyticsModel(
      period: '7 hari terakhir',
      avgDependenceScore: 60.0,
      dependenceChangePercentage: -8.5,
      dependenceChangeLabel: 'Sedikit menurun (membaik)',
      highRiskDays: 2,
      totalSurveysWeek: 5,
      dailyTrend: [
        DailyTrend(
          date: '2025-04-01',
          dependenceScore: 55,
          category: 'sedang',
          confidence: 0.80,
        ),
        DailyTrend(
          date: '2025-04-02',
          dependenceScore: 58,
          category: 'sedang',
          confidence: 0.78,
        ),
        DailyTrend(
          date: '2025-04-03',
          dependenceScore: 62,
          category: 'sedang',
          confidence: 0.85,
        ),
        DailyTrend(
          date: '2025-04-04',
          dependenceScore: 57,
          category: 'sedang',
          confidence: 0.82,
        ),
        DailyTrend(
          date: '2025-04-05',
          dependenceScore: 59,
          category: 'sedang',
          confidence: 0.79,
        ),
        DailyTrend(
          date: '2025-04-06',
          dependenceScore: 56,
          category: 'sedang',
          confidence: 0.83,
        ),
        DailyTrend(
          date: '2025-04-07',
          dependenceScore: 60,
          category: 'sedang',
          confidence: 0.81,
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get avgDependenceInt => avgDependenceScore.round().clamp(0, 100);

  String get dependenceChangeLabelFormatted {
    final sign = dependenceChangePercentage >= 0 ? '+' : '';
    return '$sign${dependenceChangePercentage.toStringAsFixed(0)}%';
  }

  String get insightText {
    if (totalSurveysWeek == 0) {
      return 'Isi kuesioner untuk melihat insight pertamamu.';
    }
    if (dependenceChangeLabel.isNotEmpty) return dependenceChangeLabel;
    // Untuk dependensi: turun = baik, naik = buruk
    if (dependenceChangePercentage < 0) {
      return 'Skor ketergantungan turun ${dependenceChangePercentage.abs().toStringAsFixed(0)}% — ada perbaikan!';
    }
    if (dependenceChangePercentage > 0) {
      return 'Skor ketergantungan naik ${dependenceChangePercentage.toStringAsFixed(0)}% — perlu perhatian.';
    }
    return 'Tidak ada perubahan signifikan minggu ini.';
  }

  List<ChartPoint> get dependenceTrendPoints => dailyTrend
      .map(
        (t) => ChartPoint(label: t.shortDate, value: t.dependenceScore / 100),
      )
      .toList();
}

// ── DailyTrend ─────────────────────────────────────────────────────────────────
class DailyTrend {
  final String date;
  final double dependenceScore;
  final String category;
  final double confidence;

  const DailyTrend({
    required this.date,
    required this.dependenceScore,
    required this.category,
    required this.confidence,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      date: json['date']?.toString() ?? '',
      dependenceScore: _toDouble(json['dependence_score']),
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

  String get shortDate {
    try {
      final p = date.split('-');
      return '${p[2]}/${p[1]}';
    } catch (_) {
      return date;
    }
  }
}

// ── ChartPoint ─────────────────────────────────────────────────────────────────
class ChartPoint {
  final String label;
  final double value;
  const ChartPoint({required this.label, required this.value});
}
