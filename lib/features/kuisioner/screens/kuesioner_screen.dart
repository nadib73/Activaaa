import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/questionnaire_provider.dart';
import '../widgets/question_option_card.dart';
import '../widgets/question_slider.dart';
import '../widgets/question_scale_picker.dart';
import '../../hasil_prediksi/screens/hasil_prediksi_screen.dart';
import '../../auth/providers/auth_provider.dart';

// true  = hitung lokal (backend belum siap)
// false = kirim ke Laravel → data masuk MongoDB
const bool _useMockSurvey = false;

class KuesionerScreen extends ConsumerStatefulWidget {
  const KuesionerScreen({super.key});

  @override
  ConsumerState<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends ConsumerState<KuesionerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionnaireProvider.notifier).reset();
      // Isi otomatis field dari data user yang sudah login
      _prefillFromUser();
    });
  }

  void _prefillFromUser() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref
        .read(questionnaireProvider.notifier)
        .setFromUserData(
          gender: user.gender,
          region: user.region,
          educationLevel: user.educationLevel,
          incomeLevel: 'Low', // fallback jika belum ada di UserModel
          dailyRole: 'Student',
          deviceType: 'Android',
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _nextPage() {
    if (ref.read(questionnaireProvider).isLastPage) {
      _submit();
    } else {
      ref.read(questionnaireProvider.notifier).nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    final state = ref.read(questionnaireProvider);
    if (state.currentPage > 0) {
      ref.read(questionnaireProvider.notifier).prevPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final success = await ref
        .read(questionnaireProvider.notifier)
        .submit(useMock: _useMockSurvey);

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
                  _PageInfoDiri(),
                  _PagePenggunaanDigital(),
                  _PageAktivitasTidur(),
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
    const titles = [
      'Info Diri',
      'Penggunaan Digital',
      'Aktivitas & Tidur',
      'Kondisi Mental',
    ];
    const subtitles = [
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
          onPressed: state.isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: state.isLoading
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
                      state.isLastPage ? 'Lihat Hasil Analisis' : 'Lanjut',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      state.isLastPage
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
// HALAMAN 1 — INFO DIRI
// Q1: Usia (input angka)
// ═══════════════════════════════════════════════════════════════════════════════

class _PageInfoDiri extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PageInfoDiri> createState() => _PageInfoDiriState();
}

class _PageInfoDiriState extends ConsumerState<_PageInfoDiri> {
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final age = ref.read(questionnaireProvider).form.age;
    _ageController = TextEditingController(text: age > 0 ? age.toString() : '');
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info field dari register
          _buildRegisterInfoBanner(),
          const SizedBox(height: 28),

          // Q1 — Usia
          _QuestionBlock(
            number: 1,
            question: 'Berapa usia kamu saat ini?',
            hint: 'Masukkan usia antara 13 hingga 50 tahun',
            child: _buildAgeInput(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterInfoBanner() {
    final form = ref.watch(questionnaireProvider).form;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.teal,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Data dari akun kamu',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Gender', form.gender),
          _infoRow('Region', form.region),
          _infoRow('Pendidikan', form.educationLevel),
          const SizedBox(height: 4),
          const Text(
            'Data di atas diambil otomatis dari profil akun kamu.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Text(
            ': $value',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeInput(QuestionnaireNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '20',
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 24),
            suffixText: 'tahun',
            suffixStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
            filled: true,
            fillColor: AppColors.bgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          onChanged: (val) {
            final age = int.tryParse(val) ?? 0;
            if (age >= 13 && age <= 50) {
              notifier.setAge(age);
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade400,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              'Rentang usia yang valid: 13 – 50 tahun',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 2 — PENGGUNAAN DIGITAL
// Q8–Q12: Semua pilihan (option card)
// ═══════════════════════════════════════════════════════════════════════════════

class _PagePenggunaanDigital extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          // Q2 — Lama pakai perangkat
          _QuestionBlock(
            number: 2,
            question:
                'Berapa lama kamu menggunakan perangkat digital per hari?',
            hint: 'Total semua perangkat (HP, laptop, tablet, dll)',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Sedikit',
                  subtitle: 'Kurang dari 2 jam',
                  isSelected: form.deviceHoursPerDay == 1.5,
                  onTap: () => notifier.setDeviceHours(1.5),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 2–4 jam',
                  isSelected: form.deviceHoursPerDay == 3.0,
                  onTap: () => notifier.setDeviceHours(3.0),
                ),
                QuestionOptionCard(
                  label: 'Sedang',
                  subtitle: 'Sekitar 4–7 jam',
                  isSelected: form.deviceHoursPerDay == 5.5,
                  onTap: () => notifier.setDeviceHours(5.5),
                ),
                QuestionOptionCard(
                  label: 'Lama',
                  subtitle: 'Sekitar 7–10 jam',
                  isSelected: form.deviceHoursPerDay == 8.5,
                  onTap: () => notifier.setDeviceHours(8.5),
                ),
                QuestionOptionCard(
                  label: 'Sangat Lama',
                  subtitle: 'Lebih dari 10 jam',
                  isSelected: form.deviceHoursPerDay == 12.0,
                  onTap: () => notifier.setDeviceHours(12.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q3 — Buka HP
          _QuestionBlock(
            number: 3,
            question: 'Seberapa sering kamu membuka HP dalam sehari?',
            hint: 'Estimasi berapa kali kamu cek / unlock HP',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Jarang',
                  subtitle: 'Kurang dari 20 kali',
                  isSelected: form.phoneUnlocksPerDay == 10,
                  onTap: () => notifier.setPhoneUnlocks(10),
                ),
                QuestionOptionCard(
                  label: 'Kadang-kadang',
                  subtitle: 'Sekitar 20–50 kali',
                  isSelected: form.phoneUnlocksPerDay == 35,
                  onTap: () => notifier.setPhoneUnlocks(35),
                ),
                QuestionOptionCard(
                  label: 'Cukup Sering',
                  subtitle: 'Sekitar 50–100 kali',
                  isSelected: form.phoneUnlocksPerDay == 75,
                  onTap: () => notifier.setPhoneUnlocks(75),
                ),
                QuestionOptionCard(
                  label: 'Sering',
                  subtitle: 'Sekitar 100–200 kali',
                  isSelected: form.phoneUnlocksPerDay == 150,
                  onTap: () => notifier.setPhoneUnlocks(150),
                ),
                QuestionOptionCard(
                  label: 'Sangat Sering',
                  subtitle: 'Lebih dari 200 kali',
                  isSelected: form.phoneUnlocksPerDay == 250,
                  onTap: () => notifier.setPhoneUnlocks(250),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q4 — Notifikasi
          _QuestionBlock(
            number: 4,
            question: 'Berapa banyak notifikasi yang kamu terima per hari?',
            hint: 'Gabungan semua aplikasi: WA, IG, email, dll',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Hampir Tidak Ada',
                  subtitle: 'Kurang dari 50 notifikasi',
                  isSelected: form.notificationsPerDay == 30,
                  onTap: () => notifier.setNotifications(30),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 50–200 notifikasi',
                  isSelected: form.notificationsPerDay == 100,
                  onTap: () => notifier.setNotifications(100),
                ),
                QuestionOptionCard(
                  label: 'Lumayan',
                  subtitle: 'Sekitar 200–500 notifikasi',
                  isSelected: form.notificationsPerDay == 300,
                  onTap: () => notifier.setNotifications(300),
                ),
                QuestionOptionCard(
                  label: 'Banyak',
                  subtitle: 'Sekitar 500–1000 notifikasi',
                  isSelected: form.notificationsPerDay == 700,
                  onTap: () => notifier.setNotifications(700),
                ),
                QuestionOptionCard(
                  label: 'Sangat Banyak',
                  subtitle: 'Lebih dari 1000 notifikasi',
                  isSelected: form.notificationsPerDay == 1100,
                  onTap: () => notifier.setNotifications(1100),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q5 — Sosmed
          _QuestionBlock(
            number: 5,
            question: 'Berapa lama kamu menggunakan media sosial per hari?',
            hint: 'Instagram, TikTok, Twitter, YouTube, dll',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Tidak Pakai',
                  subtitle: 'Hampir tidak pernah',
                  isSelected: form.socialMediaMinutes == 0,
                  onTap: () => notifier.setSocialMediaMinutes(0),
                ),
                QuestionOptionCard(
                  label: 'Kurang dari 1 Jam',
                  subtitle: 'Sekitar 30 menit',
                  isSelected: form.socialMediaMinutes == 30,
                  onTap: () => notifier.setSocialMediaMinutes(30),
                ),
                QuestionOptionCard(
                  label: '1–3 Jam',
                  subtitle: 'Sekitar 2 jam per hari',
                  isSelected: form.socialMediaMinutes == 120,
                  onTap: () => notifier.setSocialMediaMinutes(120),
                ),
                QuestionOptionCard(
                  label: '3–5 Jam',
                  subtitle: 'Sekitar 4 jam per hari',
                  isSelected: form.socialMediaMinutes == 240,
                  onTap: () => notifier.setSocialMediaMinutes(240),
                ),
                QuestionOptionCard(
                  label: 'Lebih dari 5 Jam',
                  subtitle: 'Sangat banyak waktu di sosmed',
                  isSelected: form.socialMediaMinutes == 400,
                  onTap: () => notifier.setSocialMediaMinutes(400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q6 — Belajar/Kerja produktif
          _QuestionBlock(
            number: 6,
            question: 'Seberapa produktif kamu belajar atau bekerja per hari?',
            hint: 'Waktu fokus tanpa distraksi',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Hampir Tidak Ada',
                  subtitle: 'Kurang dari 30 menit',
                  isSelected: form.studyMinutes == 10,
                  onTap: () => notifier.setStudyMinutes(10),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 30 menit – 1 jam',
                  isSelected: form.studyMinutes == 60,
                  onTap: () => notifier.setStudyMinutes(60),
                ),
                QuestionOptionCard(
                  label: 'Cukup',
                  subtitle: 'Sekitar 1–3 jam',
                  isSelected: form.studyMinutes == 150,
                  onTap: () => notifier.setStudyMinutes(150),
                ),
                QuestionOptionCard(
                  label: 'Produktif',
                  subtitle: 'Sekitar 3–5 jam',
                  isSelected: form.studyMinutes == 300,
                  onTap: () => notifier.setStudyMinutes(300),
                ),
                QuestionOptionCard(
                  label: 'Sangat Produktif',
                  subtitle: 'Lebih dari 5 jam fokus',
                  isSelected: form.studyMinutes == 400,
                  onTap: () => notifier.setStudyMinutes(400),
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
// HALAMAN 3 — AKTIVITAS & TIDUR
// Q7: slider hari olahraga
// Q8: slider jam tidur
// Q9: pilihan kualitas tidur
// ═══════════════════════════════════════════════════════════════════════════════

class _PageAktivitasTidur extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          // Q7 — Hari olahraga
          _QuestionBlock(
            number: 7,
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
                _buildActivityDays(form.physicalActivityDays),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Q8 — Jam tidur
          _QuestionBlock(
            number: 8,
            question: 'Berapa jam kamu tidur per malam?',
            hint: 'Rata-rata dalam 7 hari terakhir',
            child: QuestionSlider(
              value: form.sleepHours,
              min: 3,
              max: 11,
              divisions: 16,
              unit: 'jam',
              minLabel: '3 jam',
              maxLabel: '11 jam',
              activeColor: const Color(0xFF6366F1),
              onChanged: (v) => notifier.setSleepHours(v),
            ),
          ),
          const SizedBox(height: 32),

          // Q9 — Kualitas tidur (pilihan)
          _QuestionBlock(
            number: 9,
            question: 'Bagaimana kualitas tidurmu secara umum?',
            hint: 'Pilih yang paling menggambarkan tidurmu',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Buruk',
                  subtitle: 'Sering terbangun, tidak segar',
                  isSelected: form.sleepQuality == 1.0,
                  onTap: () => notifier.setSleepQuality(1.0),
                ),
                QuestionOptionCard(
                  label: 'Buruk',
                  subtitle: 'Kadang terbangun, kurang segar',
                  isSelected: form.sleepQuality == 2.0,
                  onTap: () => notifier.setSleepQuality(2.0),
                ),
                QuestionOptionCard(
                  label: 'Cukup',
                  subtitle: 'Tidur cukup tapi tidak optimal',
                  isSelected: form.sleepQuality == 3.0,
                  onTap: () => notifier.setSleepQuality(3.0),
                ),
                QuestionOptionCard(
                  label: 'Baik',
                  subtitle: 'Tidur nyenyak, terasa segar',
                  isSelected: form.sleepQuality == 4.0,
                  onTap: () => notifier.setSleepQuality(4.0),
                ),
                QuestionOptionCard(
                  label: 'Sangat Baik',
                  subtitle: 'Tidur sangat nyenyak & berkualitas',
                  isSelected: form.sleepQuality == 5.0,
                  onTap: () => notifier.setSleepQuality(5.0),
                ),
              ],
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
// Q10: Anxiety 0–27
// Q11: Depresi  0–27
// Q12: Stres    1–10
// Q13: Happiness 0–10
// ═══════════════════════════════════════════════════════════════════════════════

class _PageKondisiMental extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          _buildDisclaimer(),
          const SizedBox(height: 24),

          // Q10 — Anxiety (0–27, invertColor: tinggi = merah)
          _QuestionBlock(
            number: 10,
            question: 'Seberapa sering kamu merasa cemas atau gelisah?',
            hint: '0 = tidak pernah cemas, 27 = sangat sering cemas',
            child: QuestionScalePicker(
              value: form.anxietyScore,
              min: 0,
              max: 27,
              lowLabel: 'Tidak Pernah',
              highLabel: 'Sangat Sering',
              invertColor: true,
              onChanged: (v) => notifier.setAnxietyScore(v.toDouble()),
            ),
          ),
          const SizedBox(height: 28),

          // Q11 — Depresi (0–27, invertColor: tinggi = merah)
          _QuestionBlock(
            number: 11,
            question:
                'Seberapa sering kamu merasa sedih atau tidak bersemangat?',
            hint: '0 = tidak pernah, 27 = hampir setiap saat',
            child: QuestionScalePicker(
              value: form.depressionScore,
              min: 0,
              max: 27,
              lowLabel: 'Tidak Pernah',
              highLabel: 'Hampir Setiap Saat',
              invertColor: true,
              onChanged: (v) => notifier.setDepressionScore(v.toDouble()),
            ),
          ),
          const SizedBox(height: 28),

          // Q12 — Stres (1–10, invertColor: tinggi = merah)
          _QuestionBlock(
            number: 12,
            question: 'Seberapa tinggi tingkat stres kamu saat ini?',
            hint: '1 = sangat santai, 10 = sangat stres',
            child: QuestionScalePicker(
              value: form.stressLevel,
              min: 1,
              max: 10,
              lowLabel: 'Sangat Santai',
              highLabel: 'Sangat Stres',
              invertColor: true,
              onChanged: (v) => notifier.setStressLevel(v.toDouble()),
            ),
          ),
          const SizedBox(height: 28),

          // Q13 — Happiness (0–10, normal: tinggi = hijau)
          _QuestionBlock(
            number: 13,
            question: 'Seberapa bahagia kamu belakangan ini?',
            hint: '0 = sangat tidak bahagia, 10 = sangat bahagia',
            child: QuestionScalePicker(
              value: form.happinessScore,
              min: 0,
              max: 10,
              lowLabel: 'Tidak Bahagia',
              highLabel: 'Sangat Bahagia',
              invertColor: false,
              onChanged: (v) => notifier.setHappinessScore(v.toDouble()),
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
        Text(
          question,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
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
        child,
      ],
    );
  }
}
