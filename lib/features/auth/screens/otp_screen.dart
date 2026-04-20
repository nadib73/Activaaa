import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/forgot_password_provider.dart';
import '../widgets/auth_error_banner.dart';
import 'reset_password_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // 6 controller untuk 6 kotak OTP
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Countdown resend OTP
  int _secondsLeft = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto focus kotak pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Countdown ──────────────────────────────────────────────────────────────

  void _startCountdown() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // ── Get OTP string ─────────────────────────────────────────────────────────

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpCode.length == 6;

  // ── Verify ─────────────────────────────────────────────────────────────────

  Future<void> _onVerify() async {
    if (!_isOtpComplete) return;

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .verifyOtp(_otpCode);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    }
  }

  // ── Resend OTP ─────────────────────────────────────────────────────────────

  Future<void> _onResend() async {
    if (!_canResend) return;

    final email = ref.read(forgotPasswordProvider).email;
    // Kosongkan semua kotak
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .sendOtp(email);

    if (success) _startCountdown();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    final isLoading = state.isLoading;
    final errorMsg = state.errorMessage;
    final email = state.email;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(email),
              _buildFormSection(isLoading: isLoading, errorMsg: errorMsg),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Section ────────────────────────────────────────────────────────────

  Widget _buildTopSection(String email) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.amber,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cek Email Kamu',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Kami mengirimkan kode OTP 6 digit ke\n'),
                TextSpan(
                  text: email.isNotEmpty ? email : '...',
                  style: const TextStyle(
                    color: AppColors.tealLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Section ───────────────────────────────────────────────────────────

  Widget _buildFormSection({
    required bool isLoading,
    required String? errorMsg,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          // Error banner
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg),
            const SizedBox(height: 20),
          ],
          // Label
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masukkan Kode OTP',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 6 Kotak OTP
          _buildOtpBoxes(),
          const SizedBox(height: 32),
          // Verify button
          _buildVerifyButton(isLoading),
          const SizedBox(height: 24),
          // Resend countdown
          _buildResendSection(),
        ],
      ),
    );
  }

  // ── OTP Boxes ──────────────────────────────────────────────────────────────

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _buildOtpBox(i)),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.bgWhite,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controllers[index].text.isNotEmpty
                  ? AppColors.teal
                  : AppColors.lightBorder,
              width: _controllers[index].text.isNotEmpty ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.teal, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            // Maju ke kotak berikutnya
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            // Mundur ke kotak sebelumnya saat hapus
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // update warna border
        },
      ),
    );
  }

  // ── Verify Button ──────────────────────────────────────────────────────────

  Widget _buildVerifyButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (isLoading || !_isOtpComplete) ? null : _onVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.5),
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
                    'Memverifikasi...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Verifikasi OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Resend Section ─────────────────────────────────────────────────────────

  Widget _buildResendSection() {
    return Column(
      children: [
        if (!_canResend) ...[
          Text(
            'Kirim ulang OTP dalam $_secondsLeft detik',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // Progress countdown
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _secondsLeft / 60,
              backgroundColor: AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 4,
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _onResend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: AppColors.teal, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Kirim Ulang OTP',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
