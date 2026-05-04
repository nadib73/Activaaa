//lib/features/kuisoner/providers/questionnaire_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';
import '../../hasil_prediksi/models/confidence_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../histori/providers/histori_provider.dart';
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

  // Halaman 1: Penggunaan Digital (Q1–Q5)
  // Halaman 2: Aktivitas & Tidur (Q6–Q8)
  // Halaman 3: Kondisi Mental (Q9–Q12)
  static const int totalPages = 3;

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
  final Ref _ref;
  final String? _userId;

  QuestionnaireNotifier(this._service, this._ref, [this._userId])
    : super(QuestionnaireState(form: QuestionnaireModel.empty()));

  // ── Setter Q1–Q5 (pilihan → nilai ML) ────────────────────────────────────
  // Q1: Lama pakai perangkat → device_hours_per_day
  // Pilihan: Sangat sedikit=1.5, Sedikit=3, Sedang=5.5, Lama=8.5, Sangat lama=12
  void setDeviceHours(double v) =>
      updateForm(state.form.copyWith(deviceHoursPerDay: v));

  // Q2: Buka HP per hari → phone_unlocks_per_day
  // Pilihan: Jarang=10, Kadang=35, Cukup sering=75, Sering=150, Sangat sering=250
  void setPhoneUnlocks(int v) =>
      updateForm(state.form.copyWith(phoneUnlocksPerDay: v));

  // Q3: Notifikasi per hari → notifications_per_day
  // Pilihan: Hampir tidak ada=30, Sedikit=100, Lumayan=300, Banyak=700, Sangat banyak=1100
  void setNotifications(int v) =>
      updateForm(state.form.copyWith(notificationsPerDay: v));

  // Q4: Durasi sosmed → social_media_minutes
  // Pilihan: Tidak pakai=0, <1jam=30, 1-3jam=120, 3-5jam=240, >5jam=400
  void setSocialMediaMinutes(int v) =>
      updateForm(state.form.copyWith(socialMediaMinutes: v));

  // Q5: Produktif belajar/kerja → study_minutes
  // Pilihan: Hampir tidak ada=10, Sedikit=60, Cukup=150, Produktif=300, Sangat produktif=400
  void setStudyMinutes(int v) =>
      updateForm(state.form.copyWith(studyMinutes: v));

  // ── Setter Q6–Q7 (slider) ────────────────────────────────────────────────
  void setPhysicalActivityDays(int v) =>
      updateForm(state.form.copyWith(physicalActivityDays: v));
  void setSleepHours(double v) =>
      updateForm(state.form.copyWith(sleepHours: v));

  // ── Setter Q8 (pilihan → nilai ML) ───────────────────────────────────────
  // Pilihan: Sangat buruk=1, Buruk=2, Cukup=3, Baik=4, Sangat baik=5
  void setSleepQuality(double v) =>
      updateForm(state.form.copyWith(sleepQuality: v));

  // ── Setter Q9–Q12 (skala) ────────────────────────────────────────────────
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

      // Otomatis tambahkan ke histori agar langsung muncul di list
      if (result != null) {
        _ref.read(historiProvider.notifier).addItem(result);
      }

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
    double dep = 30.0;
    dep += (f.deviceHoursPerDay / 12) * 30;
    dep += (f.phoneUnlocksPerDay / 250) * 25;
    dep += (f.depressionScore / 27) * 15;
    dep -= (f.sleepQuality / 5) * 10;
    dep -= (f.sleepHours / 11) * 8;
    dep += (f.notificationsPerDay / 1100) * 12;
    dep -= (f.happinessScore / 10) * 8;
    dep = dep.clamp(10.0, 100.0);

    String category;
    if (dep >= 65) {
      category = 'tinggi';
    } else if (dep >= 40) {
      category = 'sedang';
    } else {
      category = 'rendah';
    }

    final confidence = 0.75 + (dep / 100) * 0.15;

    final penyebab = <String>[];
    final rekomendasi = <RecommendationItem>[];

    if (f.socialMediaMinutes > 120) {
      penyebab.add('screen_time_tinggi');
      rekomendasi.add(
        RecommendationItem(
          tag: 'social_media',
          isi:
              'Kurangi media sosial — kamu menggunakannya '
              '${(f.socialMediaMinutes / 60).toStringAsFixed(1)} jam/hari. Targetkan max 1 jam.',
        ),
      );
    }
    if (f.notificationsPerDay > 300) {
      penyebab.add('notifikasi_berlebihan');
      rekomendasi.add(
        RecommendationItem(
          tag: 'notifications',
          isi:
              'Matikan notifikasi tidak penting. '
              'Kamu menerima sekitar ${f.notificationsPerDay} notif/hari.',
        ),
      );
    }
    if (f.sleepHours < 7) {
      penyebab.add('tidur_kurang');
      rekomendasi.add(
        RecommendationItem(
          tag: 'sleep',
          isi:
              'Tidur minimal 7–8 jam/malam. '
              'Saat ini ${f.sleepHours.toStringAsFixed(1)} jam kurang optimal.',
        ),
      );
    }
    if (f.physicalActivityDays < 3) {
      penyebab.add('kurang_olahraga');
      rekomendasi.add(
        RecommendationItem(
          tag: 'exercise',
          isi:
              'Olahraga minimal 3x/minggu. '
              'Aktivitas fisik terbukti meningkatkan fokus dan produktivitas.',
        ),
      );
    }
    if (f.stressLevel >= 7) {
      penyebab.add('stress_tinggi');
      rekomendasi.add(
        RecommendationItem(
          tag: 'stress',
          isi:
              'Stresmu cukup tinggi. Coba meditasi 10 menit/hari atau teknik deep breathing.',
        ),
      );
    }
    if (rekomendasi.isEmpty) {
      rekomendasi.add(
        const RecommendationItem(
          tag: 'general',
          isi:
              'Gaya hidup digitalmu sudah cukup baik! Pertahankan kebiasaan positif ini.',
        ),
      );
    }

    final now = DateTime.now();
    final weekNum = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7)
        .ceil();
    final weekGroup = '${now.year}-W${weekNum.toString().padLeft(2, '0')}';

    return MlResultModel(
      id: 'local_\${now.millisecondsSinceEpoch}',
      userId: _userId ?? 'local_user',
      questionnaireId: 'q_\${now.millisecondsSinceEpoch}',
      digitalDependenceScore: double.parse(dep.toStringAsFixed(1)),
      category: category,
      confidence: ConfidenceModel.fromJson(confidence),
      penyebab: penyebab,
      rekomendasi: rekomendasi.take(4).toList(),
      pembukaan: '',
      highRiskFlag: dep >= 70 ? 1 : 0,
      summary:
          'Skor ketergantungan digital kamu: \${dep.toStringAsFixed(0)} ($category).',
      aiModel: 'mock',
      weekGroup: weekGroup,
      createdAt: now,
    );
  }

  // ── Fetch Latest ────────────────────────────────────────────────────────────
  Future<MlResultModel?> fetchLatestResult() async {
    state = state.copyWith(
      status: QuestionnaireStatus.loading,
      errorMessage: null,
    );
    try {
      final data = await _service.getLatest();
      if (data == null) {
        state = state.copyWith(status: QuestionnaireStatus.initial);
        return null;
      }

      // Backend biasanya mengirimkan { questionnaire: {...}, ml_result: {...} }
      // atau langsung MlResult model. Kita coba parse ml_result nya.
      final mlJson = data['ml_result'] as Map<String, dynamic>?;
      if (mlJson != null) {
        // Inject data questionnaire jika ada
        if (data['questionnaire'] != null && mlJson['questionnaire'] == null) {
          mlJson['questionnaire'] = data['questionnaire'];
        }
        final result = MlResultModel.fromJson(mlJson);
        state = state.copyWith(
          status: QuestionnaireStatus.success,
          result: result,
        );
        return result;
      }

      state = state.copyWith(status: QuestionnaireStatus.initial);
      return null;
    } catch (e) {
      state = state.copyWith(
        status: QuestionnaireStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset({bool keepResult = false}) {
    state = QuestionnaireState(
      form: QuestionnaireModel.empty(),
      result: keepResult ? state.result : null,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
      final service = ref.watch(questionnaireServiceProvider);
      final user = ref.watch(currentUserProvider);
      return QuestionnaireNotifier(service, ref, user?.id);
    });

final questionnaireResultProvider = Provider<MlResultModel?>((ref) {
  return ref.watch(questionnaireProvider).result;
});
