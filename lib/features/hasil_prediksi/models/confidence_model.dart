// lib/features/hasil_prediksi/models/confidence_model.dart

class ConfidenceDistanceModel {
  final double confidencePct;
  final double mahalanobisDistance;
  final String zone;

  const ConfidenceDistanceModel({
    required this.confidencePct,
    required this.mahalanobisDistance,
    required this.zone,
  });

  factory ConfidenceDistanceModel.fromJson(Map<String, dynamic> json) {
    return ConfidenceDistanceModel(
      confidencePct: _toDouble(json['confidence_pct']),
      mahalanobisDistance: _toDouble(json['mahalanobis_distance']),
      zone: json['zone']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
    'confidence_pct': confidencePct,
    'mahalanobis_distance': mahalanobisDistance,
    'zone': zone,
  };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class ConfidenceModel {
  final double confidenceFinalPct; // 0–100
  final String label; // Rendah / Sedang / Tinggi / Sangat Tinggi
  final double confidenceByScorePct;
  final ConfidenceDistanceModel? byDistance;

  const ConfidenceModel({
    required this.confidenceFinalPct,
    required this.label,
    required this.confidenceByScorePct,
    this.byDistance,
  });

  // ── Computed ───────────────────────────────────────────────────────────────

  /// Nilai 0.0–1.0, untuk backward-compat dengan kode lama
  double get asRatio => confidenceFinalPct / 100.0;

  /// Nilai bulat 0–100, untuk ditampilkan di UI
  int get asInt => confidenceFinalPct.round();

  // ── fromJson ───────────────────────────────────────────────────────────────
  //
  // Backward-compatible:
  // - Jika backend lama kirim `double` (misal 0.82) → wrap jadi ConfidenceModel
  // - Jika backend baru kirim object → parse normal

  factory ConfidenceModel.fromJson(dynamic json) {
    // Backend lama: confidence = angka (0.0–1.0 atau 0–100)
    if (json is num) {
      final pct = json > 1.0 ? json.toDouble() : json.toDouble() * 100;
      return ConfidenceModel(
        confidenceFinalPct: double.parse(pct.toStringAsFixed(2)),
        label: _labelFromPct(pct),
        confidenceByScorePct: double.parse(pct.toStringAsFixed(2)),
        byDistance: null,
      );
    }

    // Backend baru: confidence = object
    final map = json as Map<String, dynamic>;
    return ConfidenceModel(
      confidenceFinalPct: _toDouble(map['confidence_final_pct']),
      label: map['label']?.toString() ?? 'Rendah',
      confidenceByScorePct: _toDouble(map['confidence_by_score_pct']),
      byDistance: map['confidence_by_distance'] is Map<String, dynamic>
          ? ConfidenceDistanceModel.fromJson(
              map['confidence_by_distance'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'confidence_final_pct': confidenceFinalPct,
    'label': label,
    'confidence_by_score_pct': confidenceByScorePct,
    'confidence_by_distance': byDistance?.toJson(),
  };

  static String _labelFromPct(double pct) {
    if (pct >= 75) return 'Sangat Tinggi';
    if (pct >= 60) return 'Tinggi';
    if (pct >= 40) return 'Sedang';
    return 'Rendah';
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
