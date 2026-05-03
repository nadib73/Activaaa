// lib/features/hasil_prediksi/screens/hasil_prediksi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../kuisioner/providers/questionnaire_provider.dart';
import '../models/ml_result_model.dart';
import '../providers/result_provider.dart';
import '../widgets/score_circle.dart';
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
                                const SizedBox(height: 24),
                                _buildLargeScoreCircle(data),
                                const SizedBox(height: 24),
                                _buildRiskBadge(data),
                                const SizedBox(height: 24),
                                _buildConfidenceDetail(data),
                                const SizedBox(height: 24),
                                if (data.pembukaan.isNotEmpty)
                                  _buildPembukaanCard(data),
                                const SizedBox(height: 24),
                                _buildRekomendasiCard(data),
                                const SizedBox(height: 24),
                                _buildHistoriButton(context),
                                const SizedBox(height: 40),
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

  // ── Score Components ───────────────────────────────────────────────────────

  Widget _buildLargeScoreCircle(MlResultModel data) {
    return Center(
      child: ScoreCircle(
        score: data.dependenceInt.toString(),
        label: 'Skor Dependensi Digital',
        color: AppColors.red,
        percent: (data.digitalDependenceScore / 100).clamp(0.0, 1.0),
        size: 160,
        fontSize: 48,
      ),
    );
  }

  Widget _buildRiskBadge(MlResultModel data) {
    final cat = data.category.toLowerCase();
    final isHigh = cat == 'tinggi' || cat == 'high';
    final isMedium = cat == 'sedang' || cat == 'moderate';

    final color = isHigh
        ? AppColors.red
        : (isMedium ? AppColors.amber : AppColors.teal);

    final label = isHigh
        ? 'Tinggi — Risiko Ketergantungan'
        : (isMedium ? 'Sedang — Perlu Perhatian' : 'Rendah — Pola Hidup Sehat');

    final icon = isHigh
        ? Icons.warning_amber_rounded
        : (isMedium
              ? Icons.info_outline_rounded
              : Icons.check_circle_outline_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceDetail(MlResultModel data) {
    final confidence = data.confidence.confidenceFinalPct;
    const color = AppColors.teal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tingkat Kepercayaan Analisis (Confidence)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(color),
            ),
          ),
          if (data.confidence.label.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Status: ${data.confidence.label}',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pembukaan AI ───────────────────────────────────────────────────────────

  Widget _buildPembukaanCard(MlResultModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.teal, size: 20),
              SizedBox(width: 10),
              Text(
                'Analisis AI',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.pembukaan,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.7,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.teal, size: 20),
              SizedBox(width: 10),
              Text(
                'Rekomendasi Untukmu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...data.recommendations.map(_buildRekItem),
        ],
      ),
    );
  }

  Widget _buildRekItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Histori Button ─────────────────────────────────────────────────────────

  Widget _buildHistoriButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoriScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lihat Riwayat Analisis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
