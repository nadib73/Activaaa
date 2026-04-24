import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// true  = mock login (backend belum terhubung)
// false = real API Laravel
// ─────────────────────────────────────────────────────────────────────────────
const bool _useMockLogin = false;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _emailValid = false;
  bool _passValid = false;

  // ── Validation state ────────────────────────────────────────────────────
  bool _submitted = false; // true setelah pertama kali tekan "Masuk"
  String? _emailError;
  String? _passwordError;

  // ── Shake animation ─────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Validasi ───────────────────────────────────────────────────────────────

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  void _onEmailChanged(String val) {
    final trimmed = val.trim();
    setState(() {
      _emailValid = _emailRegex.hasMatch(trimmed);
      if (_submitted) {
        _emailError = _validateEmail(trimmed);
      }
    });
    ref.read(authProvider.notifier).clearError();
  }

  void _onPasswordChanged(String val) {
    setState(() {
      _passValid = val.length >= 6;
      if (_submitted) {
        _passwordError = _validatePassword(val);
      }
    });
    ref.read(authProvider.notifier).clearError();
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Mark as submitted so errors show from now on
    setState(() {
      _submitted = true;
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
    });

    // If any validation errors exist, shake & vibrate
    if (_emailError != null || _passwordError != null) {
      _shakeController.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    bool success = false;

    if (_useMockLogin) {
      // ── Mock login — tidak butuh server ───────────────────────────────────
      success = await ref
          .read(authProvider.notifier)
          .mockLogin(email: email, password: password);
    } else {
      // ── Real API — aktifkan saat backend siap ─────────────────────────────
      success = await ref
          .read(authProvider.notifier)
          .login(email: email, password: password);
    }

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(isLoading),
              _buildFormSection(isLoading: isLoading, errorMsg: errorMsg),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Section ────────────────────────────────────────────────────────────

  Widget _buildTopSection(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 28),
          Text(
            isLoading ? 'Halo lagi!' : 'Selamat datang kembali',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Masuk ke Akun',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau gaya hidup digitalmu hari ini',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Icon(
        Icons.check_box_outlined,
        color: AppColors.teal,
        size: 28,
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
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg),
            const SizedBox(height: 20),
          ],
          // Banner info akun demo
          if (_useMockLogin) ...[
            _buildMockBanner(),
            const SizedBox(height: 20),
          ],
          AuthTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isValid: _emailValid,
            errorText: _emailError,
            onChanged: _onEmailChanged,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passwordController,
            isPassword: true,
            isValid: _passValid,
            errorText: _passwordError,
            onChanged: _onPasswordChanged,
          ),
          const SizedBox(height: 8),
          _buildForgotPasswordLink(),
          const SizedBox(height: 20),
          _buildLoginButton(isLoading),
          const SizedBox(height: 20),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  // ── Mock Banner ────────────────────────────────────────────────────────────

  Widget _buildMockBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 15),
              SizedBox(width: 6),
              Text(
                'Mode Demo — Backend belum terhubung',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Tombol isi otomatis
          GestureDetector(
            onTap: () {
              _emailController.text = 'rizky@gmail.com';
              _passwordController.text = '123456';
              setState(() {
                _emailValid = true;
                _passValid = true;
                _emailError = null;
                _passwordError = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '  Tap untuk isi otomatis akun demo',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login Button ───────────────────────────────────────────────────────────

  Widget _buildLoginButton(bool isLoading) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onLogin,
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
                      'Sedang masuk...',
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
                    Icon(Icons.arrow_forward_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Masuk',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Register Link ──────────────────────────────────────────────────────────

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
        child: const Text(
          'Lupa Password?',
          style: TextStyle(
            color: AppColors.teal,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(color: AppColors.textMuted),
              ),
              TextSpan(
                text: 'Daftar sekarang',
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
