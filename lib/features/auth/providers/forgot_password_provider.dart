import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum ForgotPasswordStatus { initial, loading, success, error }

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String email; // email yang dipakai reset
  final bool otpVerified; // sudah verifikasi OTP?
  final String? errorMessage;
  final String? successMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.email = '',
    this.otpVerified = false,
    this.errorMessage = null,
    this.successMessage = null,
  });

  bool get isLoading => status == ForgotPasswordStatus.loading;
  bool get isSuccess => status == ForgotPasswordStatus.success;
  bool get isError => status == ForgotPasswordStatus.error;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    bool? otpVerified,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      otpVerified: otpVerified ?? this.otpVerified,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthService _service;

  ForgotPasswordNotifier(this._service) : super(const ForgotPasswordState());

  // ── Step 1: Kirim OTP ke email ─────────────────────────────────────────────
  Future<bool> sendOtp(String email) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      email: email.trim().toLowerCase(),
      errorMessage: null,
    );
    try {
      await _service.forgotPassword(email);
      state = state.copyWith(
        status: ForgotPasswordStatus.success,
        successMessage: 'Kode OTP telah dikirim ke $email',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Step 2: Verifikasi OTP ─────────────────────────────────────────────────
  Future<bool> verifyOtp(String otpCode) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      errorMessage: null,
    );
    try {
      await _service.verifyOtp(email: state.email, otpCode: otpCode.trim());
      state = state.copyWith(
        status: ForgotPasswordStatus.success,
        otpVerified: true,
        successMessage: 'OTP valid! Silakan buat password baru.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Step 3: Reset password baru ────────────────────────────────────────────
  Future<bool> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      errorMessage: null,
    );
    try {
      await _service.resetPassword(
        email: state.email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(
        status: ForgotPasswordStatus.success,
        successMessage: 'Password berhasil direset!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Reset state ────────────────────────────────────────────────────────────
  void reset() => state = const ForgotPasswordState();
  void clearError() => state = state.copyWith(errorMessage: null);
}

// ── Provider ───────────────────────────────────────────────────────────────────

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<
      ForgotPasswordNotifier,
      ForgotPasswordState
    >((ref) {
      final service = ref.watch(authServiceProvider);
      return ForgotPasswordNotifier(service);
    });
