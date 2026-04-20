import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/questionnaire_provider.dart';
import '../widgets/question_option_card.dart';
import '../widgets/question_slider.dart';
import '../widgets/question_scale_picker.dart';
import '../../hasil_prediksi/screens/hasil_prediksi_screen.dart';

class KuesionerScreen extends ConsumerStatefulWidget {
  const KuesionerScreen({super.key});

  @override
  ConsumerState<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends ConsumerState<KuesionerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Reset form setiap kali masuk kuesioner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionnaireProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _nextPage() {
    final notifier = ref.read(questionnaireProvider.notifier);
    final state = ref.read(questionnaireProvider);

    if (state.isLastPage) {
      _submit();
    } else {
      notifier.nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    final notifier = ref.read(questionnaireProvider.notifier);
    final state = ref.read(questionnaireProvider);

    if (state.currentPage > 0) {
      notifier.prevPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    // useMock: true  → hitung lokal (sekarang)
    // useMock: false → kirim ke Laravel saat backend siap
    final success = await ref
        .read(questionnaireProvider.notifier)
        .submit(useMock: true);

    if (success && mounted) {
      final result = ref.read(questionnaireProvider).result;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HasilPrediksiScreen(result: result)),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionnaireProvider);

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PageInformasiUmum(),
                  _PagePenggunaanPerangkat(),
                  _PageAktivitasHarian(),
                  _PageKondisiMental(),
                ],
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(QuestionnaireState state) {
    final titles = [
      'Informasi Umum',
      'Penggunaan Perangkat',
      'Aktivitas Harian',
      'Kondisi Mental',
    ];
    final subtitles = [
      'Ceritakan sedikit tentang dirimu',
      'Seberapa sering kamu pakai gadget?',
      'Bagaimana keseharianmu?',
      'Bagaimana kondisi mentalmu belakangan ini?',
    ];

    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              GestureDetector(
                onTap: _prevPage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textDark,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[state.currentPage],
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitles[state.currentPage],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Counter halaman
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.currentPage + 1} / ${QuestionnaireState.totalPages}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.currentPage + 1) / QuestionnaireState.totalPages,
              backgroundColor: AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(QuestionnaireState state) {
    final isLoading = state.isLoading;
    final isLastPage = state.isLastPage;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Memproses...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Lihat Hasil Analisis' : 'Lanjut',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastPage
                          ? Icons.analytics_outlined
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 1 — INFORMASI UMUM
// ═══════════════════════════════════════════════════════════════════════════════

class _PageInformasiUmum extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q1 — Daily Role
          _QuestionBlock(
            number: 1,
            question: 'Apa peran utama kamu sehari-hari?',
            hint: 'Pilih yang paling sesuai dengan aktivitasmu',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Pelajar / Mahasiswa',
                  subtitle: 'Sekolah, kuliah, atau kursus',
                  icon: Icons.school_outlined,
                  isSelected: form.dailyRole == 'Student',
                  onTap: () => notifier.setDailyRole('Student'),
                ),
                QuestionOptionCard(
                  label: 'Karyawan / Pekerja',
                  subtitle: 'Bekerja penuh atau paruh waktu',
                  icon: Icons.work_outline_rounded,
                  isSelected: form.dailyRole == 'Employee',
                  onTap: () => notifier.setDailyRole('Employee'),
                ),
                QuestionOptionCard(
                  label: 'Wirausaha',
                  subtitle: 'Menjalankan bisnis sendiri',
                  icon: Icons.business_center_outlined,
                  isSelected: form.dailyRole == 'Entrepreneur',
                  onTap: () => notifier.setDailyRole('Entrepreneur'),
                ),
                QuestionOptionCard(
                  label: 'Freelancer',
                  subtitle: 'Pekerja lepas / remote',
                  icon: Icons.laptop_outlined,
                  isSelected: form.dailyRole == 'Freelancer',
                  onTap: () => notifier.setDailyRole('Freelancer'),
                ),
                QuestionOptionCard(
                  label: 'Lainnya',
                  subtitle: 'Ibu rumah tangga, pensiunan, dll',
                  icon: Icons.person_outline_rounded,
                  isSelected: form.dailyRole == 'Other',
                  onTap: () => notifier.setDailyRole('Other'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q2 — Income Level
          _QuestionBlock(
            number: 2,
            question: 'Berapa kisaran pendapatan bulananmu?',
            hint: 'Informasi ini bersifat rahasia dan hanya untuk analisis',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Rendah',
                  subtitle: 'Di bawah Rp 3 juta / bulan',
                  icon: Icons.trending_down_rounded,
                  isSelected: form.incomeLevel == 'Low',
                  onTap: () => notifier.setIncomeLevel('Low'),
                ),
                QuestionOptionCard(
                  label: 'Menengah',
                  subtitle: 'Rp 3 juta – Rp 10 juta / bulan',
                  icon: Icons.trending_flat_rounded,
                  isSelected: form.incomeLevel == 'Middle',
                  onTap: () => notifier.setIncomeLevel('Middle'),
                ),
                QuestionOptionCard(
                  label: 'Tinggi',
                  subtitle: 'Di atas Rp 10 juta / bulan',
                  icon: Icons.trending_up_rounded,
                  isSelected: form.incomeLevel == 'High',
                  onTap: () => notifier.setIncomeLevel('High'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q3 — Device Type
          _QuestionBlock(
            number: 3,
            question: 'Apa perangkat utama yang kamu pakai sehari-hari?',
            hint: 'Pilih perangkat yang paling sering kamu gunakan',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Smartphone',
                  subtitle: 'Android atau iPhone',
                  icon: Icons.smartphone_rounded,
                  isSelected: form.deviceType == 'Smartphone',
                  onTap: () => notifier.setDeviceType('Smartphone'),
                ),
                QuestionOptionCard(
                  label: 'Laptop / PC',
                  subtitle: 'Komputer atau laptop',
                  icon: Icons.laptop_rounded,
                  isSelected: form.deviceType == 'Laptop',
                  onTap: () => notifier.setDeviceType('Laptop'),
                ),
                QuestionOptionCard(
                  label: 'Tablet',
                  subtitle: 'iPad atau tablet Android',
                  icon: Icons.tablet_rounded,
                  isSelected: form.deviceType == 'Tablet',
                  onTap: () => notifier.setDeviceType('Tablet'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 2 — PENGGUNAAN PERANGKAT
// ═══════════════════════════════════════════════════════════════════════════════

class _PagePenggunaanPerangkat extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q4 — Device Hours
          _QuestionBlock(
            number: 4,
            question: 'Berapa jam kamu menggunakan perangkat per hari?',
            hint: 'Termasuk HP, laptop, tablet — total semua perangkat',
            child: QuestionSlider(
              value: form.deviceHoursPerDay,
              min: 0,
              max: 16,
              divisions: 32,
              unit: 'jam',
              minLabel: '0 jam',
              maxLabel: '16 jam',
              onChanged: (v) => notifier.setDeviceHours(v),
            ),
          ),
          const SizedBox(height: 32),

          // Q5 — Phone Unlocks
          _QuestionBlock(
            number: 5,
            question: 'Berapa kali kamu membuka HP dalam sehari?',
            hint: 'Estimasi berapa kali kamu unlock / cek HP per hari',
            child: QuestionSlider(
              value: form.phoneUnlocksPerDay.toDouble(),
              min: 0,
              max: 300,
              divisions: 60,
              unit: 'kali',
              minLabel: '0 kali',
              maxLabel: '300+ kali',
              activeColor: AppColors.amber,
              onChanged: (v) => notifier.setPhoneUnlocks(v.round()),
            ),
          ),
          const SizedBox(height: 32),

          // Q6 — Notifications
          _QuestionBlock(
            number: 6,
            question: 'Berapa notifikasi yang kamu terima per hari?',
            hint: 'Gabungan semua aplikasi: WA, IG, email, dll',
            child: QuestionSlider(
              value: form.notificationsPerDay.toDouble(),
              min: 0,
              max: 500,
              divisions: 50,
              unit: 'notif',
              minLabel: '0',
              maxLabel: '500+',
              activeColor: AppColors.red,
              onChanged: (v) => notifier.setNotifications(v.round()),
            ),
          ),
          const SizedBox(height: 32),

          // Q7 — Social Media Minutes
          _QuestionBlock(
            number: 7,
            question: 'Berapa menit kamu menggunakan media sosial per hari?',
            hint: 'Instagram, TikTok, Twitter, YouTube, dll',
            child: QuestionSlider(
              value: form.socialMediaMinutes.toDouble(),
              min: 0,
              max: 480,
              divisions: 48,
              unit: 'menit',
              minLabel: '0 menit',
              maxLabel: '8 jam',
              activeColor: const Color(0xFF8B5CF6),
              onChanged: (v) => notifier.setSocialMediaMinutes(v.round()),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 3 — AKTIVITAS HARIAN
// ═══════════════════════════════════════════════════════════════════════════════

class _PageAktivitasHarian extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q8 — Study Minutes
          _QuestionBlock(
            number: 8,
            question: 'Berapa menit kamu belajar atau bekerja per hari?',
            hint: 'Waktu fokus untuk belajar / bekerja tanpa distraksi',
            child: QuestionSlider(
              value: form.studyMinutes.toDouble(),
              min: 0,
              max: 600,
              divisions: 60,
              unit: 'menit',
              minLabel: '0 menit',
              maxLabel: '10 jam',
              activeColor: AppColors.blue,
              onChanged: (v) => notifier.setStudyMinutes(v.round()),
            ),
          ),
          const SizedBox(height: 32),

          // Q9 — Physical Activity Days
          _QuestionBlock(
            number: 9,
            question: 'Berapa hari kamu berolahraga dalam seminggu?',
            hint: 'Olahraga minimal 30 menit, termasuk jalan kaki',
            child: Column(
              children: [
                QuestionSlider(
                  value: form.physicalActivityDays.toDouble(),
                  min: 0,
                  max: 7,
                  divisions: 7,
                  unit: 'hari',
                  minLabel: 'Tidak pernah',
                  maxLabel: 'Setiap hari',
                  activeColor: AppColors.green,
                  onChanged: (v) => notifier.setPhysicalActivityDays(v.round()),
                ),
                const SizedBox(height: 12),
                // Visual feedback hari olahraga
                _buildActivityDays(form.physicalActivityDays),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Q10 — Sleep Hours
          _QuestionBlock(
            number: 10,
            question: 'Berapa jam kamu tidur per malam?',
            hint: 'Rata-rata tidur dalam 7 hari terakhir',
            child: QuestionSlider(
              value: form.sleepHours,
              min: 2,
              max: 12,
              divisions: 20,
              unit: 'jam',
              minLabel: '2 jam',
              maxLabel: '12 jam',
              activeColor: const Color(0xFF6366F1),
              onChanged: (v) => notifier.setSleepHours(v),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivityDays(int days) {
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isActive = i < days;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.green
                    : AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? AppColors.green
                      : AppColors.green.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                isActive ? Icons.directions_run_rounded : Icons.remove_rounded,
                color: isActive ? Colors.white : AppColors.green,
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNames[i],
              style: TextStyle(
                color: isActive ? AppColors.green : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 4 — KONDISI MENTAL
// ═══════════════════════════════════════════════════════════════════════════════

class _PageKondisiMental extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info disclaimer
          _buildDisclaimer(),
          const SizedBox(height: 20),

          // Q11 — Sleep Quality
          _QuestionBlock(
            number: 11,
            question: 'Seberapa baik kualitas tidurmu?',
            hint: '1 = sangat buruk, 10 = sangat nyenyak',
            child: QuestionScalePicker(
              value: form.sleepQuality,
              lowLabel: 'Sangat Buruk',
              highLabel: 'Sangat Nyenyak',
              activeColor: const Color(0xFF6366F1),
              onChanged: (v) => notifier.setSleepQuality(v),
            ),
          ),
          const SizedBox(height: 28),

          // Q12 — Anxiety Score
          _QuestionBlock(
            number: 12,
            question: 'Seberapa sering kamu merasa cemas?',
            hint: '1 = tidak pernah, 10 = sangat sering',
            child: QuestionScalePicker(
              value: form.anxietyScore,
              lowLabel: 'Tidak Pernah',
              highLabel: 'Sangat Sering',
              activeColor: AppColors.amber,
              onChanged: (v) => notifier.setAnxietyScore(v),
            ),
          ),
          const SizedBox(height: 28),

          // Q13 — Depression Score
          _QuestionBlock(
            number: 13,
            question:
                'Seberapa sering kamu merasa sedih atau tidak bersemangat?',
            hint: '1 = tidak pernah, 10 = hampir setiap hari',
            child: QuestionScalePicker(
              value: form.depressionScore,
              lowLabel: 'Tidak Pernah',
              highLabel: 'Hampir Setiap Hari',
              activeColor: AppColors.red,
              onChanged: (v) => notifier.setDepressionScore(v),
            ),
          ),
          const SizedBox(height: 28),

          // Q14 — Stress Level
          _QuestionBlock(
            number: 14,
            question: 'Seberapa tinggi tingkat stres kamu saat ini?',
            hint: '1 = sangat santai, 10 = sangat stres',
            child: QuestionScalePicker(
              value: form.stressLevel,
              lowLabel: 'Sangat Santai',
              highLabel: 'Sangat Stres',
              activeColor: AppColors.red,
              onChanged: (v) => notifier.setStressLevel(v),
            ),
          ),
          const SizedBox(height: 28),

          // Q15 — Happiness Score
          _QuestionBlock(
            number: 15,
            question: 'Seberapa bahagia kamu hari ini?',
            hint: '1 = sangat tidak bahagia, 10 = sangat bahagia',
            child: QuestionScalePicker(
              value: form.happinessScore,
              lowLabel: 'Tidak Bahagia',
              highLabel: 'Sangat Bahagia',
              activeColor: AppColors.green,
              onChanged: (v) => notifier.setHappinessScore(v),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            color: AppColors.amber,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Jawab dengan jujur. Semua jawaban bersifat rahasia '
              'dan hanya digunakan untuk analisis gaya hidupmu.',
              style: TextStyle(
                color: AppColors.amber,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE — QUESTION BLOCK
// ═══════════════════════════════════════════════════════════════════════════════

class _QuestionBlock extends StatelessWidget {
  final int number;
  final String question;
  final String? hint;
  final Widget child;

  const _QuestionBlock({
    required this.number,
    required this.question,
    required this.child,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge nomor pertanyaan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'PERTANYAAN $number',
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Teks pertanyaan
        Text(
          question,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        // Hint
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Widget jawaban
        child,
      ],
    );
  }
}
