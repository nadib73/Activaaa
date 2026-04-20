/// Model untuk hasil prediksi ML.
/// Sesuai dengan collection `ml_results` di MongoDB.
class MlResultModel {
  final String id;
  final String userId;
  final String questionnaireId;
  final double focusScore;
  final double productivityScore;
  final double digitalDependenceScore;
  final bool highRiskFlag;
  final List<String> recommendations;
  final DateTime createdAt;

  const MlResultModel({
    required this.id,
    required this.userId,
    required this.questionnaireId,
    required this.focusScore,
    required this.productivityScore,
    required this.digitalDependenceScore,
    required this.highRiskFlag,
    required this.recommendations,
    required this.createdAt,
  });

  // ── From JSON (dari response Laravel) ─────────────────────────────────────
  factory MlResultModel.fromJson(Map<String, dynamic> json) {
    return MlResultModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      questionnaireId: json['questionnaire_id'] ?? '',
      focusScore: (json['focus_score'] ?? 0).toDouble(),
      productivityScore: (json['productivity_score'] ?? 0).toDouble(),
      digitalDependenceScore: (json['digital_dependence_score'] ?? 0)
          .toDouble(),
      highRiskFlag: json['high_risk_flag'] ?? false,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'questionnaire_id': questionnaireId,
      'focus_score': focusScore,
      'productivity_score': productivityScore,
      'digital_dependence_score': digitalDependenceScore,
      'high_risk_flag': highRiskFlag,
      'recommendations': recommendations,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Skor focus dalam skala 0–100 (int)
  int get focusInt => (focusScore * 100).round();

  /// Skor produktivitas dalam skala 0–100 (int)
  int get productivityInt => productivityScore.round().clamp(0, 100);

  /// Skor dependensi dalam skala 0–100 (int)
  int get dependenceInt => digitalDependenceScore.round().clamp(0, 100);

  /// Label risiko berdasarkan high_risk_flag
  String get riskLabel => highRiskFlag ? 'High Risk' : 'Normal';

  /// Tanggal format: "07 APR"
  String get formattedDate {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];
    return '${createdAt.day.toString().padLeft(2, '0')} '
        '${months[createdAt.month]}';
  }

  /// Tanggal format: "07" (hari saja)
  String get dayStr => createdAt.day.toString().padLeft(2, '0');

  /// Tanggal format: "APR" (bulan saja)
  String get monthStr {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];
    return months[createdAt.month];
  }

  @override
  String toString() =>
      'MlResultModel(focus: $focusScore, prod: $productivityScore, dep: $digitalDependenceScore)';
}
