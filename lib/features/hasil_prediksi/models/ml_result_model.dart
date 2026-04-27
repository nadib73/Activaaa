/// Model untuk hasil prediksi ML.
/// Sesuai MlResult.php + formatResult() PrediksiController.php
///
/// Catatan relasi dari MlResult.php:
/// recommendations() → hasOne(Recommendation::class, 'result_id')
/// Artinya recommendations adalah SATU object, bukan array langsung.
/// Tapi di formatResult() Laravel sudah di-flatten:
/// 'recommendations' => $result->recommendations
/// Yang bisa berupa object Recommendation atau array teks.
class MlResultModel {
  final String id;
  final String userId;
  final String questionnaireId;
  final double focusScore;
  final double productivityScore;
  final double digitalDependenceScore;
  final bool highRiskFlag;
  final String riskLevel;
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
    this.riskLevel = 'Rendah',
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory MlResultModel.fromJson(Map<String, dynamic> json) {
    final q = json['questionnaire'] as Map<String, dynamic>?;
    final userId =
        q?['user_id']?.toString() ?? json['user_id']?.toString() ?? '';
    final qId =
        q?['_id']?.toString() ??
        q?['id']?.toString() ??
        json['questionnaire_id']?.toString() ??
        '';

    return MlResultModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: userId,
      questionnaireId: qId,
      focusScore: _toDouble(json['focus_score']),
      productivityScore: _toDouble(json['productivity_score']),
      digitalDependenceScore: _toDouble(json['digital_dependence_score']),
      highRiskFlag: json['high_risk_flag'] as bool? ?? false,
      riskLevel: json['risk_level']?.toString() ?? 'Rendah',
      recommendations: _parseRecommendations(json['recommendations']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // ── Parse recommendations ──────────────────────────────────────────────────
  // MlResult.php → recommendations() hasOne Recommendation
  // Bisa berupa:
  // 1. List<String>            → langsung pakai
  // 2. List<Map>               → ambil field 'recommendation_text' atau 'text'
  // 3. Map (single object)     → ambil field 'recommendations' (array di dalam)
  // 4. null                    → return []
  static List<String> _parseRecommendations(dynamic raw) {
    if (raw == null) return [];

    // Kasus 3: Object Recommendation tunggal (hasOne)
    if (raw is Map<String, dynamic>) {
      final inner = raw['recommendations'];
      if (inner is List) return _parseRecommendations(inner);
      final text =
          raw['recommendation_text']?.toString() ?? raw['text']?.toString();
      return text != null && text.isNotEmpty ? [text] : [];
    }

    // Kasus 1 & 2: List
    if (raw is List) {
      final result = <String>[];
      for (final item in raw) {
        if (item is String && item.isNotEmpty) {
          result.add(item);
        } else if (item is Map) {
          final text =
              item['recommendation_text']?.toString() ??
              item['text']?.toString() ??
              '';
          if (text.isNotEmpty) result.add(text);
        }
      }
      return result;
    }

    return [];
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'questionnaire_id': questionnaireId,
    'focus_score': focusScore,
    'productivity_score': productivityScore,
    'digital_dependence_score': digitalDependenceScore,
    'high_risk_flag': highRiskFlag,
    'risk_level': riskLevel,
    'recommendations': recommendations,
    'created_at': createdAt.toIso8601String(),
  };

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get focusInt => (focusScore * 100).round().clamp(0, 100);
  int get productivityInt => productivityScore.round().clamp(0, 100);
  int get dependenceInt => digitalDependenceScore.round().clamp(0, 100);

  String get dayStr => createdAt.day.toString().padLeft(2, '0');
  String get monthStr {
    const m = [
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
    return m[createdAt.month];
  }

  String get formattedDate => '$dayStr $monthStr';

  @override
  String toString() =>
      'MlResult(focus: $focusScore, prod: $productivityScore, dep: $digitalDependenceScore, risk: $riskLevel)';
}
