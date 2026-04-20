/// Model untuk data analytics / insight.
/// Sesuai dengan collection `analytics_logs` di MongoDB.
class AnalyticsModel {
  final String userId;
  final double avgFocus7Days;
  final double focusChangePercentage;
  final double avgProductivity7Days;
  final double productivityChangePercentage;
  final double avgDependence7Days;
  final double dependenceChangePercentage;
  final double screenTimeChangePercentage;
  final List<ChartPoint> focusTrend;
  final List<ChartPoint> productivityTrend;
  final List<ChartPoint> dependenceTrend;
  final DateTime createdAt;

  const AnalyticsModel({
    required this.userId,
    required this.avgFocus7Days,
    required this.focusChangePercentage,
    required this.avgProductivity7Days,
    required this.productivityChangePercentage,
    required this.avgDependence7Days,
    required this.dependenceChangePercentage,
    required this.screenTimeChangePercentage,
    required this.focusTrend,
    required this.productivityTrend,
    required this.dependenceTrend,
    required this.createdAt,
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      userId: json['user_id'] ?? '',
      avgFocus7Days: (json['avg_focus_7_days'] ?? 0).toDouble(),
      focusChangePercentage: (json['focus_change_percentage'] ?? 0).toDouble(),
      avgProductivity7Days: (json['avg_productivity_7_days'] ?? 0).toDouble(),
      productivityChangePercentage:
          (json['productivity_change_percentage'] ?? 0).toDouble(),
      avgDependence7Days: (json['avg_dependence_7_days'] ?? 0).toDouble(),
      dependenceChangePercentage: (json['dependence_change_percentage'] ?? 0)
          .toDouble(),
      screenTimeChangePercentage: (json['screen_time_change_percentage'] ?? 0)
          .toDouble(),
      focusTrend: _parsePoints(json['focus_trend']),
      productivityTrend: _parsePoints(json['productivity_trend']),
      dependenceTrend: _parsePoints(json['dependence_trend']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static List<ChartPoint> _parsePoints(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Mock Data (dipakai sebelum backend siap) ───────────────────────────────
  factory AnalyticsModel.mock() {
    return AnalyticsModel(
      userId: 'mock_user',
      avgFocus7Days: 0.82,
      focusChangePercentage: 12.0,
      avgProductivity7Days: 75.0,
      productivityChangePercentage: 5.0,
      avgDependence7Days: 60.0,
      dependenceChangePercentage: -8.0,
      screenTimeChangePercentage: -20.0,
      focusTrend: [
        ChartPoint(label: 'M1', value: 0.55),
        ChartPoint(label: 'M2', value: 0.60),
        ChartPoint(label: 'M3', value: 0.58),
        ChartPoint(label: 'M4', value: 0.65),
        ChartPoint(label: 'M5', value: 0.72),
        ChartPoint(label: 'M6', value: 0.80),
        ChartPoint(label: 'M7', value: 0.82),
      ],
      productivityTrend: [
        ChartPoint(label: 'M1', value: 0.42),
        ChartPoint(label: 'M2', value: 0.45),
        ChartPoint(label: 'M3', value: 0.43),
        ChartPoint(label: 'M4', value: 0.50),
        ChartPoint(label: 'M5', value: 0.52),
        ChartPoint(label: 'M6', value: 0.55),
        ChartPoint(label: 'M7', value: 0.58),
      ],
      dependenceTrend: [
        ChartPoint(label: 'M1', value: 0.30),
        ChartPoint(label: 'M2', value: 0.35),
        ChartPoint(label: 'M3', value: 0.38),
        ChartPoint(label: 'M4', value: 0.42),
        ChartPoint(label: 'M5', value: 0.48),
        ChartPoint(label: 'M6', value: 0.55),
        ChartPoint(label: 'M7', value: 0.60),
      ],
      createdAt: DateTime.now(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Format persentase dengan tanda + / -
  String formatChange(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(0)}%';
  }

  String get focusChangeLabel => formatChange(focusChangePercentage);
  String get productivityChangeLabel =>
      formatChange(productivityChangePercentage);
  String get dependenceChangeLabel => formatChange(dependenceChangePercentage);
  String get screenTimeChangeLabel => formatChange(screenTimeChangePercentage);

  /// Insight otomatis berdasarkan data
  String get insightText {
    final parts = <String>[];

    if (focusChangePercentage > 0) {
      parts.add(
        'Focus score kamu naik ${focusChangePercentage.toStringAsFixed(0)}%',
      );
    } else if (focusChangePercentage < 0) {
      parts.add(
        'Focus score kamu turun ${focusChangePercentage.abs().toStringAsFixed(0)}%',
      );
    }

    if (screenTimeChangePercentage < 0) {
      parts.add(
        'Screen time turun ${screenTimeChangePercentage.abs().toStringAsFixed(0)} menit per hari',
      );
    }

    return parts.isNotEmpty
        ? '${parts.join('. ')} dibanding minggu lalu.'
        : 'Tidak ada perubahan signifikan minggu ini.';
  }
}

/// Satu titik data untuk chart.
class ChartPoint {
  final String label;
  final double value;

  const ChartPoint({required this.label, required this.value});

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}
