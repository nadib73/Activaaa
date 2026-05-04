// lib/features/hasil_prediksi/models/ml_result_model.dart

import 'confidence_model.dart';

class RecommendationItem {
  final String tag;
  final String isi;

  const RecommendationItem({required this.tag, required this.isi});

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      tag: json['tag']?.toString() ?? 'general',
      isi: json['isi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'tag': tag, 'isi': isi};
}

class MlResultModel {
  final String id;
  final String userId;
  final String questionnaireId;
  final double digitalDependenceScore;
  final String category;
  final ConfidenceModel confidence; // ✅ BERUBAH: double → ConfidenceModel
  final List<String> penyebab;
  final List<RecommendationItem> rekomendasi;
  final String summary;
  final String aiModel;
  final String weekGroup;
  final DateTime createdAt;

  const MlResultModel({
    required this.id,
    required this.userId,
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

  // ── Computed ───────────────────────────────────────────────────────────────

  int get dependenceInt => digitalDependenceScore.round();

  /// Backward-compat: dulu `(confidence * 100).round()`
  int get confidenceInt => confidence.asInt;

  /// List<String> untuk ditampilkan di UI
  List<String> get recommendations => rekomendasi.map((r) => r.isi).toList();

  String get formattedDate {
    final d = createdAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String get dayStr => createdAt.day.toString().padLeft(2, '0');

  String get monthStr {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
      'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
    ];
    return months[createdAt.month - 1];
  }

  String get riskLevel {
    final cat = category.toLowerCase();
    if (cat == 'tinggi' || cat == 'high') return 'Risiko Tinggi';
    if (cat == 'sedang' || cat == 'moderate') return 'Perlu Perhatian';
    return 'Hidup Sehat';
  }

  // ── fromJson ───────────────────────────────────────────────────────────────
  //
  // Handles dua struktur response dari Laravel:
  //
  // A) Nested (dari SurveyController — PRODUCTION):
  // {
  //   "_id": "...",
  //   "questionnaire_id": "...",
  //   "ml_result": {
  //     "digital_dependence_score": 60,
  //     "category": "sedang",
  //     "confidence": {                          ← ✅ sekarang object
  //       "confidence_final_pct": 74.5,
  //       "label": "Tinggi",
  //       "confidence_by_score_pct": 81.0,
  //       "confidence_by_distance": { ... }
  //     }
  //   },
  //   "ai_analysis": { "penyebab": [...], "rekomendasi": [...], ... }
  // }
  //
  // B) Flat / mock / backend lama (confidence masih double):
  // {
  //   "_id": "...",
  //   "digital_dependence_score": 60,
  //   "confidence": 0.82,       ← backward-compat, akan di-wrap otomatis
  //   ...
  // }

  factory MlResultModel.fromJson(Map<String, dynamic> json) {
    final mlResult = json['ml_result'] as Map<String, dynamic>?;
    final aiAnalysis = json['ai_analysis'] as Map<String, dynamic>?;

    final score = _toDouble(
      mlResult?['digital_dependence_score'] ?? json['digital_dependence_score'],
    );
    final category = (mlResult?['category'] ?? json['category'] ?? 'rendah')
        .toString();

    // ✅ Parse confidence — backward-compat (double atau object)
    final rawConfidence = mlResult?['confidence'] ?? json['confidence'];
    final confidence = rawConfidence != null
        ? ConfidenceModel.fromJson(rawConfidence)
        : ConfidenceModel(
            confidenceFinalPct: 0,
            label: 'Rendah',
            confidenceByScorePct: 0,
          );

    // Ekstrak penyebab
    final rawPenyebab = aiAnalysis?['penyebab'] ?? json['penyebab'];
    final penyebab = rawPenyebab is List
        ? rawPenyebab.map((e) => e.toString()).toList()
        : <String>[];

    // Ekstrak rekomendasi
    final rawRek = aiAnalysis?['rekomendasi'] ?? json['rekomendasi'];
    final rekomendasi = rawRek is List
        ? rawRek
              .map(
                (e) => e is Map<String, dynamic>
                    ? RecommendationItem.fromJson(e)
                    : RecommendationItem(tag: 'general', isi: e.toString()),
              )
              .toList()
        : <RecommendationItem>[];

    final summary = (aiAnalysis?['summary'] ?? json['summary'] ?? '')
        .toString();
    final aiModel = (aiAnalysis?['model'] ?? json['aiModel'] ?? 'unknown')
        .toString();

    final qId =
        json['questionnaire_id']?.toString() ??
        (json['questionnaire'] as Map<String, dynamic>?)?['_id']?.toString() ??
        '';

    return MlResultModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      questionnaireId: qId,
      digitalDependenceScore: score,
      category: category,
      confidence: confidence,
      penyebab: penyebab,
      rekomendasi: rekomendasi,
      summary: summary,
      aiModel: aiModel,
      weekGroup: json['week_group']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user_id': userId,
    'questionnaire_id': questionnaireId,
    'ml_result': {
      'digital_dependence_score': digitalDependenceScore,
      'category': category,
      'confidence': confidence.toJson(), // ✅ toJson() dari ConfidenceModel
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
}
