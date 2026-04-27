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
  final MlResultModel? result;
  final bool mlFailed;

  // Halaman 1: Info Diri (Q7 usia)
  // Halaman 2: Penggunaan Digital (Q8–Q12)
  // Halaman 3: Aktivitas & Tidur (Q13–Q15)
  // Halaman 4: Kondisi Mental (Q16–Q19)
  static const int totalPages = 4;

  const QuestionnaireState({
    this.status = QuestionnaireStatus.initial,
    required this.form,
    this.currentPage = 0,
    this.errorMessage = null,
    this.result = null,
    this.mlFailed = false,
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
    bool? mlFailed,
  }) {
    return QuestionnaireState(
      status: status ?? this.status,
      form: form ?? this.form,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
      mlFailed: mlFailed ?? this.mlFailed,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  final QuestionnaireService _service;

  QuestionnaireNotifier(this._service)
    : super(QuestionnaireState(form: QuestionnaireModel.empty()));

  // ── Setter dari Register (diisi otomatis dari user data) ───────────────────
  void setFromUserData({
    required String gender,
    required String region,
    required String educationLevel,
    required String incomeLevel,
    required String dailyRole,
    required String deviceType,
  }) {
    updateForm(
      state.form.copyWith(
        gender: gender,
        region: region,
        educationLevel: educationLevel,
        incomeLevel: incomeLevel,
        dailyRole: dailyRole,
        deviceType: deviceType,
      ),
    );
  }

  // ── Setter Q7 ──────────────────────────────────────────────────────────────
  void setAge(int v) => updateForm(state.form.copyWith(age: v));

  // ── Setter Q8–Q12 (pilihan → nilai ML) ────────────────────────────────────
  // Q8: Lama pakai perangkat → device_hours_per_day
  // Pilihan: Sangat sedikit=1.5, Sedikit=3, Sedang=5.5, Lama=8.5, Sangat lama=12
  void setDeviceHours(double v) =>
      updateForm(state.form.copyWith(deviceHoursPerDay: v));

  // Q9: Buka HP per hari → phone_unlocks_per_day
  // Pilihan: Jarang=10, Kadang=35, Cukup sering=75, Sering=150, Sangat sering=250
  void setPhoneUnlocks(int v) =>
      updateForm(state.form.copyWith(phoneUnlocksPerDay: v));

  // Q10: Notifikasi per hari → notifications_per_day
  // Pilihan: Hampir tidak ada=30, Sedikit=100, Lumayan=300, Banyak=700, Sangat banyak=1100
  void setNotifications(int v) =>
      updateForm(state.form.copyWith(notificationsPerDay: v));

  // Q11: Durasi sosmed → social_media_minutes
  // Pilihan: Tidak pakai=0, <1jam=30, 1-3jam=120, 3-5jam=240, >5jam=400
  void setSocialMediaMinutes(int v) =>
      updateForm(state.form.copyWith(socialMediaMinutes: v));

  // Q12: Produktif belajar/kerja → study_minutes
  // Pilihan: Hampir tidak ada=10, Sedikit=60, Cukup=150, Produktif=300, Sangat produktif=400
  void setStudyMinutes(int v) =>
      updateForm(state.form.copyWith(studyMinutes: v));

  // ── Setter Q13–Q14 (slider) ────────────────────────────────────────────────
  void setPhysicalActivityDays(int v) =>
      updateForm(state.form.copyWith(physicalActivityDays: v));
  void setSleepHours(double v) =>
      updateForm(state.form.copyWith(sleepHours: v));

  // ── Setter Q15 (pilihan → nilai ML) ───────────────────────────────────────
  // Pilihan: Sangat buruk=1, Buruk=2, Cukup=3, Baik=4, Sangat baik=5
  void setSleepQuality(double v) =>
      updateForm(state.form.copyWith(sleepQuality: v));

  // ── Setter Q16–Q19 (skala) ────────────────────────────────────────────────
  void setAnxietyScore(double v) =>
      updateForm(state.form.copyWith(anxietyScore: v));
  void setDepressionScore(double v) =>
      updateForm(state.form.copyWith(depressionScore: v));
  void setStressLevel(double v) =>
      updateForm(state.form.copyWith(stressLevel: v));
  void setHappinessScore(double v) =>
      updateForm(state.form.copyWith(happinessScore: v));

  void updateForm(QuestionnaireModel f) => state = state.copyWith(form: f);

  // ── Navigasi ───────────────────────────────────────────────────────────────
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
  Future<bool> submit({bool useMock = false}) async {
    state = state.copyWith(
      status: QuestionnaireStatus.loading,
      errorMessage: null,
      mlFailed: false,
    );

    try {
      MlResultModel? result;

      if (useMock) {
        result = _calculateMockResult(state.form);
        await Future.delayed(const Duration(seconds: 2));
      } else {
        final submitResult = await _service.submit(state.form);
        if (!submitResult.mlSuccess) {
          state = state.copyWith(
            status: QuestionnaireStatus.error,
            errorMessage: submitResult.message,
            mlFailed: true,
          );
          return false;
        }
        result = submitResult.mlResult;
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

  MlResultModel _calculateMockResult(QuestionnaireModel f) {
    double focus = 0.85;
    focus -= (f.notificationsPerDay / 1100) * 0.30;
    focus -= (f.socialMediaMinutes / 400) * 0.15;
    focus -= (f.stressLevel / 10) * 0.10;
    focus += (f.happinessScore / 10) * 0.08;
    focus += (f.sleepHours / 11) * 0.07;
    focus += (f.studyMinutes / 400) * 0.10;
    focus = focus.clamp(0.20, 1.0);

    double prod = 70.0;
    prod += (f.studyMinutes / 400) * 20;
    prod += (f.physicalActivityDays / 7) * 10;
    prod += ((f.sleepHours - 6) / 5) * 8;
    prod -= (f.socialMediaMinutes / 400) * 15;
    prod -= (f.stressLevel / 10) * 10;
    prod -= (f.anxietyScore / 27) * 8;
    prod = prod.clamp(20.0, 100.0);

    double dep = 30.0;
    dep += (f.deviceHoursPerDay / 12) * 30;
    dep += (f.phoneUnlocksPerDay / 250) * 25;
    dep += (f.depressionScore / 27) * 15;
    dep -= (f.sleepQuality / 5) * 10;
    dep -= (f.sleepHours / 11) * 8;
    dep += (f.notificationsPerDay / 1100) * 12;
    dep -= (f.happinessScore / 10) * 8;
    dep = dep.clamp(10.0, 100.0);

    final highRisk = dep >= 65 || focus < 0.45;

    String riskLevel;
    if (highRisk || dep >= 75)
      riskLevel = 'Tinggi';
    else if (dep >= 50)
      riskLevel = 'Sedang';
    else
      riskLevel = 'Rendah';

    return MlResultModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      questionnaireId: 'q_${DateTime.now().millisecondsSinceEpoch}',
      focusScore: double.parse(focus.toStringAsFixed(2)),
      productivityScore: double.parse(prod.toStringAsFixed(1)),
      digitalDependenceScore: double.parse(dep.toStringAsFixed(1)),
      highRiskFlag: highRisk,
      riskLevel: riskLevel,
      recommendations: _generateRecommendations(f),
      createdAt: DateTime.now(),
    );
  }

  List<String> _generateRecommendations(QuestionnaireModel f) {
    final recs = <String>[];
    if (f.socialMediaMinutes > 120) {
      recs.add(
        'Kurangi media sosial — kamu menggunakannya '
        '${(f.socialMediaMinutes / 60).toStringAsFixed(1)} jam/hari. Targetkan max 1 jam.',
      );
    }
    if (f.notificationsPerDay > 300) {
      recs.add(
        'Matikan notifikasi tidak penting. '
        'Kamu menerima sekitar ${f.notificationsPerDay} notif/hari yang mengganggu fokus.',
      );
    }
    if (f.sleepHours < 7) {
      recs.add(
        'Tidur minimal 7–8 jam/malam. '
        'Saat ini ${f.sleepHours.toStringAsFixed(1)} jam kurang optimal untuk kesehatan.',
      );
    }
    if (f.physicalActivityDays < 3) {
      recs.add(
        'Olahraga minimal 3x/minggu. '
        'Aktivitas fisik terbukti meningkatkan fokus dan produktivitas.',
      );
    }
    if (f.phoneUnlocksPerDay > 75) {
      recs.add(
        'Kamu membuka HP ${f.phoneUnlocksPerDay}x/hari. '
        'Coba gunakan Digital Wellbeing untuk membatasi frekuensi.',
      );
    }
    if (f.stressLevel >= 7) {
      recs.add(
        'Stresmu cukup tinggi. Coba meditasi 10 menit/hari atau teknik deep breathing.',
      );
    }
    if (recs.isEmpty) {
      recs.add(
        'Gaya hidup digitalmu sudah cukup baik! Pertahankan kebiasaan positif ini.',
      );
    }
    return recs.take(4).toList();
  }

  void reset() => state = QuestionnaireState(form: QuestionnaireModel.empty());
}

// ── Provider ───────────────────────────────────────────────────────────────────

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
      final service = ref.watch(questionnaireServiceProvider);
      return QuestionnaireNotifier(service);
    });

final questionnaireResultProvider = Provider<MlResultModel?>((ref) {
  return ref.watch(questionnaireProvider).result;
});
