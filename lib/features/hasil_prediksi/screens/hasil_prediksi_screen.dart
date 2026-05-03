// lib/features/hasil_prediksi/screens/hasil_prediksi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../kuisioner/providers/questionnaire_provider.dart';
import '../models/ml_result_model.dart';
import '../providers/result_provider.dart';
import '../widgets/score_circle.dart';
import '../widgets/trend_bar_chart.dart';
import '../../histori/screens/histori_screen.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class HasilPrediksiScreen extends ConsumerWidget {
  /// Jika null, ambil dari questionnaireResultProvider
  final MlResultModel? result;

  const HasilPrediksiScreen({super.key, this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data =
        result ??
        ref.watch(questionnaireResultProvider) ??
        ref.watch(resultProvider).latestResult;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: data == null
                  ? _buildLoading()
                  : Column(
                      children: [
                        _buildHeader(context, data),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                _buildScoreCircles(data),
                                const SizedBox(height: 16),
                                _buildRiskBadge(data),
                                const SizedBox(height: 20),
                                _buildRekomendasiCard(data),
                                const SizedBox(height: 16),
                                _buildScoreDetailCard(data),
                                const SizedBox(height: 16),
                                _buildTrendCard(),
                                const SizedBox(height: 20),
                                _buildHistoriButton(context),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            BottomNav(currentIndex: 1, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.teal),
          SizedBox(height: 16),
          Text(
            'Menganalisis data kamu...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, MlResultModel data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 20, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Analisis',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Gaya Hidup Digital Kamu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Text(
              data.formattedDate,
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score Circles ──────────────────────────────────────────────────────────

  Widget _buildScoreCircles(MlResultModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ScoreCircle(
          score: data.dependenceInt.toString(),
          label: 'Dependensi',
          color: AppColors.red,
          percent: data.digitalDependenceScore / 100,
        ),
        ScoreCircle(
          score: '${data.confidenceInt}%',
          label: 'Confidence',
          color: AppColors.teal,
          percent: data.confidence.asRatio, // ✅ fix: pakai .asRatio
        ),
      ],
    );
  }

  // ── Risk Badge ─────────────────────────────────────────────────────────────

  Widget _buildRiskBadge(MlResultModel data) {
    final isHighRisk = data.category.toLowerCase() == 'tinggi';
    final color = isHighRisk ? AppColors.red : AppColors.teal;
    final label = isHighRisk
        ? 'Risiko Tinggi — Dependensi Digital'
        : data.category.toLowerCase() == 'sedang'
        ? 'Sedang — Perlu Perhatian'
        : 'Rendah — Gaya Hidup Digital Sehat';
    final icon = isHighRisk
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rekomendasi ────────────────────────────────────────────────────────────

  Widget _buildRekomendasiCard(MlResultModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.teal, size: 18),
              SizedBox(width: 8),
              Text(
                'Rekomendasi Personal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...data.recommendations.map(_buildRekItem),
        ],
      ),
    );
  }

  Widget _buildRekItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score Detail Card ──────────────────────────────────────────────────────

  Widget _buildScoreDetailCard(MlResultModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Skor',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _buildScoreBar(
            label: 'Dependensi Digital',
            value: data.digitalDependenceScore,
            max: 100,
            color: AppColors.red,
            display: '${data.dependenceInt}/100',
          ),
          const SizedBox(height: 12),
          _buildScoreBar(
            label: 'Confidence ML',
            value: data
                .confidence
                .confidenceFinalPct, // ✅ fix: pakai .confidenceFinalPct
            max: 100, // ✅ fix: max jadi 100 (bukan 1.0)
            color: AppColors.teal,
            display: '${data.confidenceInt}%',
          ),
          // ✅ Tampilkan label confidence & zone jika tersedia
          if (data.confidence.byDistance != null) ...[
            const SizedBox(height: 10),
            _buildConfidenceZone(data),
          ],
        ],
      ),
    );
  }

  /// Menampilkan zone Mahalanobis distance jika ada (data dari Flask baru)
  Widget _buildConfidenceZone(MlResultModel data) {
    final zone = data.confidence.byDistance?.zone ?? '-';
    final label = data.confidence.label;
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Kepercayaan: $label · $zone',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBar({
    required String label,
    required double value,
    required double max,
    required Color color,
    required String display,
  }) {
    final ratio = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              display,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ── Trend Card ─────────────────────────────────────────────────────────────

  Widget _buildTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Dependensi Digital',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          TrendBarChart(),
        ],
      ),
    );
  }

  // ── Histori Button ─────────────────────────────────────────────────────────

  Widget _buildHistoriButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoriScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lihat Histori Lengkap',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
