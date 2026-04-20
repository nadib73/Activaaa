import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/forgot_password_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _passValid = false;
  bool _konfirmValid = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  // ── Validasi ───────────────────────────────────────────────────────────────

  void _onPasswordChanged(String val) {
    setState(() {
      _passValid = val.length >= 8;
      _konfirmValid =
          val == _konfirmasiController.text &&
          _konfirmasiController.text.isNotEmpty;
    });
    ref.read(forgotPasswordProvider.notifier).clearError();
  }

  void _onKonfirmasiChanged(String val) {
    setState(() {
      _konfirmValid = val == _passwordController.text && val.isNotEmpty;
    });
    ref.read(forgotPasswordProvider.notifier).clearError();
  }

  bool get _isFormValid => _passValid && _konfirmValid;

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _onReset() async {
    if (!_isFormValid) return;

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .resetPassword(
          password: _passwordController.text,
          passwordConfirmation: _konfirmasiController.text,
        );

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon sukses
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.teal,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Password Berhasil Direset!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Password kamu berhasil diubah.\nSilakan login dengan password baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // tutup dialog
                  // Kembali ke login & hapus semua stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Login Sekarang',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    final isLoading = state.isLoading;
    final errorMsg = state.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(),
              _buildFormSection(isLoading: isLoading, errorMsg: errorMsg),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Section ────────────────────────────────────────────────────────────

  Widget _buildTopSection() {
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
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: AppColors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Buat Password Baru',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Password baru harus minimal 8 karakter\ndan berbeda dari password lama.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
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
        minHeight: MediaQuery.of(context).size.height * 0.52,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg),
            const SizedBox(height: 20),
          ],
          AuthTextField(
            label: 'Password Baru',
            hint: 'Min. 8 karakter',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passwordController,
            isPassword: true,
            isValid: _passValid,
            onChanged: _onPasswordChanged,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Konfirmasi Password',
            hint: 'Ulangi password baru',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _konfirmasiController,
            isPassword: true,
            isValid: _konfirmValid,
            onChanged: _onKonfirmasiChanged,
          ),
          // Pesan tidak cocok
          if (_konfirmasiController.text.isNotEmpty && !_konfirmValid) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Password tidak cocok',
                  style: TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Syarat password
          _buildPasswordRequirements(),
          const SizedBox(height: 32),
          // Reset button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (isLoading || !_isFormValid) ? null : _onReset,
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
                          'Menyimpan...',
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
                        Icon(Icons.save_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Simpan Password Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Password Requirements ──────────────────────────────────────────────────

  Widget _buildPasswordRequirements() {
    final pass = _passwordController.text;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Syarat password:',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _reqItem('Minimal 8 karakter', pass.length >= 8),
          _reqItem('Mengandung angka', pass.contains(RegExp(r'[0-9]'))),
          _reqItem('Mengandung huruf', pass.contains(RegExp(r'[a-zA-Z]'))),
        ],
      ),
    );
  }

  Widget _reqItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: met ? AppColors.teal : Colors.grey.shade400,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: met ? AppColors.teal : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
