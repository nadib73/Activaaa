import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';
import '../models/questionnaire_model.dart';
import '../services/questionnaire_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum QuestionnaireStatus { initial, loading, success, error }

class QuestionnaireState {
  final QuestionnaireStatus status;
  final QuestionnaireModel form;
  final int currentPage;
  final String? errorMessage;
  final MlResultModel? result; // hasil setelah submit

  static const int totalPages = 4;

  const QuestionnaireState({
    this.status = QuestionnaireStatus.initial,
    required this.form,
    this.currentPage = 0,
    this.errorMessage = null,
    this.result = null,
  });

  bool get isLoading => status == QuestionnaireStatus.loading;
  bool get isSuccess => status == QuestionnaireStatus.success;
  bool get isLastPage => currentPage >= totalPages - 1;

  QuestionnaireState copyWith({
    QuestionnaireStatus? status,
    QuestionnaireModel? form,
    int? currentPage,
    String? errorMessage,
    MlResultModel? result,
  }) {
    return QuestionnaireState(
      status: status ?? this.status,
      form: form ?? this.form,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  final QuestionnaireService _service;

  QuestionnaireNotifier(this._service)
    : super(QuestionnaireState(form: QuestionnaireModel.empty()));

  // ── Update field form ──────────────────────────────────────────────────────

  void updateForm(QuestionnaireModel updatedForm) {
    state = state.copyWith(form: updatedForm);
  }

  void setDailyRole(String v) => updateForm(state.form.copyWith(dailyRole: v));
  void setIncomeLevel(String v) =>
      updateForm(state.form.copyWith(incomeLevel: v));
  void setDeviceType(String v) =>
      updateForm(state.form.copyWith(deviceType: v));
  void setDeviceHours(double v) =>
      updateForm(state.form.copyWith(deviceHoursPerDay: v));
  void setPhoneUnlocks(int v) =>
      updateForm(state.form.copyWith(phoneUnlocksPerDay: v));
  void setNotifications(int v) =>
      updateForm(state.form.copyWith(notificationsPerDay: v));
  void setSocialMediaMinutes(int v) =>
      updateForm(state.form.copyWith(socialMediaMinutes: v));
  void setStudyMinutes(int v) =>
      updateForm(state.form.copyWith(studyMinutes: v));
  void setPhysicalActivityDays(int v) =>
      updateForm(state.form.copyWith(physicalActivityDays: v));
  void setSleepHours(double v) =>
      updateForm(state.form.copyWith(sleepHours: v));
  void setSleepQuality(int v) =>
      updateForm(state.form.copyWith(sleepQuality: v));
  void setAnxietyScore(int v) =>
      updateForm(state.form.copyWith(anxietyScore: v));
  void setDepressionScore(int v) =>
      updateForm(state.form.copyWith(depressionScore: v));
  void setStressLevel(int v) => updateForm(state.form.copyWith(stressLevel: v));
  void setHappinessScore(int v) =>
      updateForm(state.form.copyWith(happinessScore: v));

  // ── Navigasi halaman ───────────────────────────────────────────────────────

  void nextPage() {
    if (!state.isLastPage) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void prevPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<bool> submit({bool useMock = true}) async {
    state = state.copyWith(
      status: QuestionnaireStatus.loading,
      errorMessage: null,
    );

    try {
      MlResultModel result;

      if (useMock) {
        // Hitung hasil dari jawaban user secara lokal
        result = _calculateMockResult(state.form);
        await Future.delayed(const Duration(seconds: 2)); // simulasi loading
      } else {
        // Kirim ke Laravel → Flask ML → dapat hasil
        final response = await _service.submit(state.form);
        result = MlResultModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
      }

      state = state.copyWith(
        status: QuestionnaireStatus.success,
        result: result,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: QuestionnaireStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Mock Calculator ────────────────────────────────────────────────────────
  // Hitung prediksi sederhana dari jawaban user
  // Sesuai dengan korelasi di dokumen ML

  MlResultModel _calculateMockResult(QuestionnaireModel f) {
    // ── Focus Score ──────────────────────────────────────────────────────────
    // Faktor utama: notifications (-), social_media (-), stress (-), happiness (+)
    double focus = 0.85;
    focus -= (f.notificationsPerDay / 500) * 0.30; // max -0.30
    focus -= (f.socialMediaMinutes / 480) * 0.15; // max -0.15
    focus -= (f.stressLevel / 10) * 0.10; // max -0.10
    focus += (f.happinessScore / 10) * 0.08; // max +0.08
    focus += (f.sleepHours / 12) * 0.07; // max +0.07
    focus += (f.studyMinutes / 600) * 0.10; // max +0.10
    focus = focus.clamp(0.20, 1.0);

    // ── Productivity Score ───────────────────────────────────────────────────
    // Faktor: study_minutes (+), physical (+), sleep (+), social_media (-)
    double prod = 70.0;
    prod += (f.studyMinutes / 600) * 20; // max +20
    prod += (f.physicalActivityDays / 7) * 10; // max +10
    prod += ((f.sleepHours - 6) / 6) * 8; // optimal 8 jam
    prod -= (f.socialMediaMinutes / 480) * 15; // max -15
    prod -= (f.stressLevel / 10) * 10; // max -10
    prod -= (f.anxietyScore / 10) * 8; // max -8
    prod = prod.clamp(20.0, 100.0);

    // ── Digital Dependence Score ─────────────────────────────────────────────
    // Faktor utama: device_hours (+), phone_unlocks (+), depression (+),
    //               sleep_quality (-), sleep_hours (-)
    double dep = 30.0;
    dep += (f.deviceHoursPerDay / 16) * 30; // max +30
    dep += (f.phoneUnlocksPerDay / 300) * 25; // max +25
    dep += (f.depressionScore / 10) * 15; // max +15
    dep -= (f.sleepQuality / 10) * 10; // max -10
    dep -= (f.sleepHours / 12) * 8; // max -8
    dep += (f.notificationsPerDay / 500) * 12; // max +12
    dep -= (f.happinessScore / 10) * 8; // max -8
    dep = dep.clamp(10.0, 100.0);

    // ── High Risk Flag ───────────────────────────────────────────────────────
    final highRisk = dep >= 65 || focus < 0.45;

    // ── Rekomendasi berdasarkan jawaban user ─────────────────────────────────
    final recs = _generateRecommendations(f, focus, prod, dep);

    return MlResultModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      questionnaireId: 'q_${DateTime.now().millisecondsSinceEpoch}',
      focusScore: double.parse(focus.toStringAsFixed(2)),
      productivityScore: double.parse(prod.toStringAsFixed(1)),
      digitalDependenceScore: double.parse(dep.toStringAsFixed(1)),
      highRiskFlag: highRisk,
      recommendations: recs,
      createdAt: DateTime.now(),
    );
  }

  // ── Generate Rekomendasi ───────────────────────────────────────────────────

  List<String> _generateRecommendations(
    QuestionnaireModel f,
    double focus,
    double prod,
    double dep,
  ) {
    final recs = <String>[];

    // Rekomendasi berdasarkan social media
    if (f.socialMediaMinutes > 180) {
      recs.add(
        'Kurangi penggunaan media sosial — kamu menghabiskan '
        '${f.socialMediaMinutes} menit/hari. Coba batasi menjadi 60 menit.',
      );
    }

    // Rekomendasi berdasarkan notifikasi
    if (f.notificationsPerDay > 200) {
      recs.add(
        'Matikan notifikasi yang tidak penting. Terlalu banyak notifikasi '
        'mengganggu fokus dan meningkatkan stres.',
      );
    }

    // Rekomendasi berdasarkan tidur
    if (f.sleepHours < 7) {
      recs.add(
        'Tingkatkan jam tidur minimal 7–8 jam per malam. '
        'Tidurmu saat ini (${f.sleepHours.toStringAsFixed(1)} jam) kurang optimal.',
      );
    }

    // Rekomendasi berdasarkan olahraga
    if (f.physicalActivityDays < 3) {
      recs.add(
        'Lakukan olahraga minimal 3x seminggu. Aktivitas fisik '
        'terbukti meningkatkan produktivitas dan mengurangi stres.',
      );
    }

    // Rekomendasi berdasarkan phone unlocks
    if (f.phoneUnlocksPerDay > 100) {
      recs.add(
        'Kamu membuka HP ${f.phoneUnlocksPerDay}x per hari. '
        'Coba gunakan fitur Digital Wellbeing untuk membatasi penggunaan.',
      );
    }

    // Rekomendasi berdasarkan stress
    if (f.stressLevel >= 7) {
      recs.add(
        'Tingkat stresmu cukup tinggi. Coba teknik relaksasi seperti '
        'meditasi 10 menit sehari atau deep breathing.',
      );
    }

    // Rekomendasi berdasarkan study minutes
    if (f.studyMinutes < 60 && f.dailyRole == 'Student') {
      recs.add(
        'Waktu belajarmu masih kurang. Coba teknik Pomodoro: '
        '25 menit fokus belajar, 5 menit istirahat.',
      );
    }

    // Rekomendasi default jika semua sudah baik
    if (recs.isEmpty) {
      recs.add('Pertahankan gaya hidup digitalmu yang sudah baik!');
      recs.add('Konsisten dengan rutinitas positifmu saat ini.');
    }

    return recs.take(4).toList(); // max 4 rekomendasi
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  void reset() {
    state = QuestionnaireState(form: QuestionnaireModel.empty());
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
      final service = ref.watch(questionnaireServiceProvider);
      return QuestionnaireNotifier(service);
    });

/// Shortcut — ambil hasil ML setelah submit
final questionnaireResultProvider = Provider<MlResultModel?>((ref) {
  return ref.watch(questionnaireProvider).result;
});
