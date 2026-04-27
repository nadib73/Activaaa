/// Semua URL endpoint API Laravel.
/// Sesuai dengan routes/api.php
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL ───────────────────────────────────────────────────────────────
  // Ganti sesuai IP laptop teman backend saat development
  // Contoh: 'http://192.168.1.x:8000/api'
  // Setelah deploy: 'https://nama-app.up.railway.app/api'
  // ── Ganti IP sesuai laptop backend ──────────────────────────────────────────
  // Flutter di HP/emulator TIDAK bisa pakai 127.0.0.1 untuk akses Laravel di laptop
  // Gunakan IP lokal laptop backend (cek dengan ipconfig / ifconfig)
  // Contoh: 'http://192.168.1.5:8000/api'
  //
  // Flutter Web di browser yang sama dengan Laravel → pakai 127.0.0.1
  // Flutter Android/iOS emulator pakai IP lokal
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Auth (PUBLIC — tanpa token) ────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // ── Auth (PROTECTED — butuh token) ────────────────────────────────────────
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // ── Survey (Kuesioner) ─────────────────────────────────────────────────────
  static const String surveys = '/surveys';
  static const String latestSurvey = '/surveys/latest';

  // ── Prediksi (Hasil ML) ────────────────────────────────────────────────────
  static const String prediksi = '/prediksi';
  static const String latestPrediksi = '/prediksi/latest';
  static const String summaryPrediksi = '/prediksi/summary';

  // ── Analytics ──────────────────────────────────────────────────────────────
  static const String analyticsInsight = '/analytics/insight';
  static const String analyticsComparison = '/analytics/comparison';
  static const String analyticsHistory = '/analytics/history';

  // ── Timeout ────────────────────────────────────────────────────────────────
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
}
