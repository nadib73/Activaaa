/// Model untuk hasil prediksi ML.
/// Sesuai format baru PrediksiController.php — embedded ml_result + ai_analysis
///
/// Response format:
/// {
///   "id": "...",
///   "ml_result": { "digital_dependence_score": 60, "category": "sedang", "confidence": 0.82 },
///   "ai_analysis": { "penyebab": [...], "rekomendasi": [...], "summary": "...", "model": "...", "generated_at": "..." },
///   "week_group": "2026-W17",
///   "questionnaire": { ... },
///   "created_at": "..."
/// }
class MlResultModel {
  final String id;
  final String questionnaireId;

  // ── Embedded ml_result ─────────────────────────────────────────────────────
  final double digitalDependenceScore;
  final String category; // "rendah", "sedang", "tinggi"
  final double confidence;

  // ── Embedded ai_analysis ──────────────────────────────────────────────────
  final List<String> penyebab;
  final List<RecommendationItem> rekomendasi;
  final String summary;
  final String aiModel;

  final String weekGroup;
  final DateTime createdAt;

  const MlResultModel({
    required this.id,
    required this.questionnaireId,
    required this.digitalDependenceScore,
    required this.category,
    required this.confidence,
    required this.penyebab,
    required this.rekomendasi,
    required this.summary,
    required this.aiModel,
    required this.weekGroup,
    required this.createdAt,
  });

  // ── From JSON ──────────────────────────────────────────────────────────────
  factory MlResultModel.fromJson(Map<String, dynamic> json) {
    // Embedded ml_result
    final mlResult = json['ml_result'] as Map<String, dynamic>? ?? {};

    // Embedded ai_analysis
    final aiAnalysis = json['ai_analysis'] as Map<String, dynamic>? ?? {};

    // Questionnaire
    final q = json['questionnaire'] as Map<String, dynamic>?;
    final qId =
        q?['_id']?.toString() ??
        q?['id']?.toString() ??
        json['questionnaire_id']?.toString() ??
        '';

    return MlResultModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      questionnaireId: qId,
      digitalDependenceScore: _toDouble(mlResult['digital_dependence_score']),
      category: mlResult['category']?.toString() ?? 'rendah',
      confidence: _toDouble(mlResult['confidence']),
      penyebab: _parseStringList(aiAnalysis['penyebab']),
      rekomendasi: _parseRekomendasi(aiAnalysis['rekomendasi']),
      summary: aiAnalysis['summary']?.toString() ?? '',
      aiModel: aiAnalysis['model']?.toString() ?? '',
      weekGroup: json['week_group']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // ── Parse helpers ──────────────────────────────────────────────────────────

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  static List<RecommendationItem> _parseRekomendasi(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) {
        if (e is Map<String, dynamic>) {
          return RecommendationItem(
            tag: e['tag']?.toString() ?? '',
            isi: e['isi']?.toString() ?? '',
          );
        }
        // Jika plain string
        return RecommendationItem(tag: '', isi: e.toString());
      }).where((r) => r.isi.isNotEmpty).toList();
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
    'questionnaire_id': questionnaireId,
    'ml_result': {
      'digital_dependence_score': digitalDependenceScore,
      'category': category,
      'confidence': confidence,
    },
    'ai_analysis': {
      'penyebab': penyebab,
      'rekomendasi': rekomendasi.map((r) => r.toJson()).toList(),
      'summary': summary,
      'model': aiModel,
    },
    'week_group': weekGroup,
    'created_at': createdAt.toIso8601String(),
  };

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get dependenceInt => digitalDependenceScore.round().clamp(0, 100);
  int get confidenceInt => (confidence * 100).round().clamp(0, 100);

  /// Label risiko: Rendah / Sedang / Tinggi
  String get riskLevel {
    switch (category.toLowerCase()) {
      case 'tinggi':
        return 'Tinggi';
      case 'sedang':
        return 'Sedang';
      default:
        return 'Rendah';
    }
  }

  /// Daftar teks rekomendasi (untuk backward compat)
  List<String> get recommendations => rekomendasi.map((r) => r.isi).toList();

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
      'MlResult(dep: $digitalDependenceScore, category: $category, confidence: $confidence)';
}

/// ── RecommendationItem ──────────────────────────────────────────────────────
class RecommendationItem {
  final String tag;
  final String isi;

  const RecommendationItem({required this.tag, required this.isi});

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      tag: json['tag']?.toString() ?? '',
      isi: json['isi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'tag': tag, 'isi': isi};
}
