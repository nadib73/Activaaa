/// Model untuk data analytics / insight.
///
/// Sesuai response AnalyticsController@insight():
/// { period, avg_focus_score, avg_productivity_score, avg_digital_dependence,
///   focus_change_percentage, focus_change_label, high_risk_days,
///   total_surveys_week, daily_trend }
///
/// Catatan AnalyticsLog.php:
/// fillable hanya: avg_focus_7_days, focus_change_percentage,
///                 avg_productivity_7_days
/// avg_digital_dependence TIDAK disimpan di AnalyticsLog,
/// tapi TETAP ada di response insight() karena dihitung langsung
/// dari MlResult — jadi parse tetap aman.
class AnalyticsModel {
  final String period;
  final double avgFocusScore;
  final double avgProductivityScore;
  final double avgDigitalDependence;
  final double focusChangePercentage;
  final String focusChangeLabel;
  final int highRiskDays;
  final int totalSurveysWeek;
  final List<DailyTrend> dailyTrend;

  const AnalyticsModel({
    required this.period,
    required this.avgFocusScore,
    required this.avgProductivityScore,
    required this.avgDigitalDependence,
    required this.focusChangePercentage,
    required this.focusChangeLabel,
    required this.highRiskDays,
    required this.totalSurveysWeek,
    required this.dailyTrend,
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawTrend = json['daily_trend'] as List? ?? [];
    return AnalyticsModel(
      period: json['period']?.toString() ?? '7 hari terakhir',
      avgFocusScore: _toDouble(json['avg_focus_score']),
      avgProductivityScore: _toDouble(json['avg_productivity_score']),
      // avg_digital_dependence ada di response tapi tidak di AnalyticsLog
      avgDigitalDependence: _toDouble(json['avg_digital_dependence']),
      focusChangePercentage: _toDouble(json['focus_change_percentage']),
      focusChangeLabel: json['focus_change_label']?.toString() ?? '',
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
      avgFocusScore: 0.82,
      avgProductivityScore: 75.0,
      avgDigitalDependence: 60.0,
      focusChangePercentage: 12.0,
      focusChangeLabel: 'Meningkat signifikan',
      highRiskDays: 2,
      totalSurveysWeek: 5,
      dailyTrend: [
        DailyTrend(
          date: '2025-04-01',
          focus: 0.75,
          productivity: 70,
          digitalDependence: 55,
          highRisk: false,
        ),
        DailyTrend(
          date: '2025-04-02',
          focus: 0.78,
          productivity: 72,
          digitalDependence: 58,
          highRisk: false,
        ),
        DailyTrend(
          date: '2025-04-03',
          focus: 0.72,
          productivity: 68,
          digitalDependence: 62,
          highRisk: true,
        ),
        DailyTrend(
          date: '2025-04-04',
          focus: 0.80,
          productivity: 74,
          digitalDependence: 57,
          highRisk: false,
        ),
        DailyTrend(
          date: '2025-04-05',
          focus: 0.79,
          productivity: 73,
          digitalDependence: 59,
          highRisk: false,
        ),
        DailyTrend(
          date: '2025-04-06',
          focus: 0.83,
          productivity: 76,
          digitalDependence: 56,
          highRisk: false,
        ),
        DailyTrend(
          date: '2025-04-07',
          focus: 0.82,
          productivity: 75,
          digitalDependence: 60,
          highRisk: false,
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get avgFocusInt => (avgFocusScore * 100).round().clamp(0, 100);
  int get avgProductivityInt => avgProductivityScore.round().clamp(0, 100);
  int get avgDependenceInt => avgDigitalDependence.round().clamp(0, 100);

  String get focusChangeLabelFormatted {
    final sign = focusChangePercentage >= 0 ? '+' : '';
    return '$sign${focusChangePercentage.toStringAsFixed(0)}%';
  }

  String get insightText {
    if (totalSurveysWeek == 0) {
      return 'Isi kuesioner untuk melihat insight pertamamu.';
    }
    if (focusChangeLabel.isNotEmpty) return focusChangeLabel;
    if (focusChangePercentage > 0) {
      return 'Focus score naik ${focusChangePercentage.toStringAsFixed(0)}% dibanding minggu lalu.';
    }
    if (focusChangePercentage < 0) {
      return 'Focus score turun ${focusChangePercentage.abs().toStringAsFixed(0)}% dibanding minggu lalu.';
    }
    return 'Tidak ada perubahan signifikan minggu ini.';
  }

  List<ChartPoint> get focusTrendPoints => dailyTrend
      .map((t) => ChartPoint(label: t.shortDate, value: t.focus))
      .toList();

  List<ChartPoint> get productivityTrendPoints => dailyTrend
      .map((t) => ChartPoint(label: t.shortDate, value: t.productivity / 100))
      .toList();

  List<ChartPoint> get dependenceTrendPoints => dailyTrend
      .map(
        (t) => ChartPoint(label: t.shortDate, value: t.digitalDependence / 100),
      )
      .toList();
}

// ── DailyTrend ─────────────────────────────────────────────────────────────────
class DailyTrend {
  final String date;
  final double focus;
  final double productivity;
  final double digitalDependence;
  final bool highRisk;

  const DailyTrend({
    required this.date,
    required this.focus,
    required this.productivity,
    required this.digitalDependence,
    required this.highRisk,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      date: json['date']?.toString() ?? '',
      focus: _toDouble(json['focus']),
      productivity: _toDouble(json['productivity']),
      digitalDependence: _toDouble(json['digital_dependence']),
      highRisk: json['high_risk'] as bool? ?? false,
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
