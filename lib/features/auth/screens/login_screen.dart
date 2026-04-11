import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import 'register_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  bool _emailValid = false;
  bool _passValid = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  void _onEmailChanged(String val) {
    setState(() {
      _emailValid = val.contains('@') && val.contains('.');
      _hasError = false;
    });
  }

  void _onPasswordChanged(String val) {
    setState(() {
      _passValid = val.length >= 6;
      _hasError = false;
    });
  }

  Future<void> _onLogin() async {
    if (!_emailValid || !_passValid) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulasi network request
    await Future.delayed(const Duration(seconds: 2));

    // Demo: hanya email tertentu yang berhasil
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (mounted) {
      if (email == 'rizky@gmail.com' && password == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [_buildTopSection(), _buildFormSection()]),
        ),
      ),
    );
  }

  // ── Top Section (dark bg) ──────────────────────────────────────────────────

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 28),
          Text(
            _isLoading ? 'Halo lagi!' : 'Selamat datang kembali',
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

  // ── Form Section (light bg) ────────────────────────────────────────────────

  Widget _buildFormSection() {
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
          if (_hasError) ...[
            const AuthErrorBanner(
              message: 'Email atau password salah.\nCoba lagi.',
            ),
            const SizedBox(height: 20),
          ],
          AuthTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isValid: _emailValid,
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
            onChanged: _onPasswordChanged,
          ),
          const SizedBox(height: 28),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading ? _buildLoadingContent() : _buildLoginContent(),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Row(
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
    );
  }

  Widget _buildLoginContent() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_forward_rounded, size: 18),
        SizedBox(width: 8),
        Text(
          'Masuk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
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
