import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_dropdown_field.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// Ganti false saat backend siap
const bool _useMockRegister = false;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _umurController = TextEditingController();

  String _gender = 'Male';
  String _pendidikan = 'Bachelor';
  String _region = 'Asia';

  static const _genderOptions = ['Male', 'Female'];
  static const _pendidikanOptions = [
    'SMA',
    'Diploma',
    'Bachelor',
    'Master',
    'Doctor',
  ];
  static const _regionOptions = [
    'Asia',
    'Europe',
    'America',
    'Africa',
    'Australia',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _umurController.dispose();
    super.dispose();
  }

  // ── Validasi ───────────────────────────────────────────────────────────────

  bool get _isFormValid {
    return _namaController.text.trim().isNotEmpty &&
        _emailController.text.contains('@') &&
        _emailController.text.contains('.') &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _konfirmasiController.text &&
        _umurController.text.isNotEmpty &&
        int.tryParse(_umurController.text) != null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _onRegister() async {
    if (!_isFormValid) return;

    // Clear error sebelumnya
    ref.read(authProvider.notifier).clearError();

    bool success = false;
    if (_useMockRegister) {
      success = await ref
          .read(authProvider.notifier)
          .mockRegister(
            name: _namaController.text.trim(),
            email: _emailController.text.trim(),
            age: int.parse(_umurController.text),
            gender: _gender,
            educationLevel: _pendidikan,
            region: _region,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .register(
            name: _namaController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _konfirmasiController.text,
            age: int.parse(_umurController.text),
            gender: _gender,
            educationLevel: _pendidikan,
            region: _region,
          );
    }

    // Navigasi manual ke Dashboard setelah register berhasil
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
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error banner
                    if (errorMsg != null) ...[
                      AuthErrorBanner(message: errorMsg),
                      const SizedBox(height: 16),
                    ],
                    _buildSectionLabel('INFORMASI AKUN'),
                    const SizedBox(height: 16),
                    _buildInfoAkunSection(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('DATA DIRI'),
                    const SizedBox(height: 16),
                    _buildDataDiriSection(),
                    const SizedBox(height: 28),
                    _buildRegisterButton(isLoading),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
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
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Isi data dirimu dengan lengkap',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── Informasi Akun ─────────────────────────────────────────────────────────

  Widget _buildInfoAkunSection() {
    return Column(
      children: [
        AuthTextField(
          label: 'Nama Lengkap',
          hint: 'Rizky Pratama',
          prefixIcon: Icons.person_outline_rounded,
          controller: _namaController,
          isValid: _namaController.text.trim().isNotEmpty,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Email',
          hint: 'nama@email.com',
          prefixIcon: Icons.mail_outline_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          isValid: _emailController.text.contains('@'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Password',
                hint: 'Min. 8',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                isPassword: true,
                isValid: _passwordController.text.length >= 8,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                label: 'Konfirmasi',
                hint: 'Ulangi',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _konfirmasiController,
                isPassword: true,
                isValid:
                    _konfirmasiController.text.isNotEmpty &&
                    _konfirmasiController.text == _passwordController.text,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Data Diri ──────────────────────────────────────────────────────────────

  Widget _buildDataDiriSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Umur',
                hint: '21',
                prefixIcon: Icons.cake_outlined,
                controller: _umurController,
                keyboardType: TextInputType.number,
                isValid:
                    _umurController.text.isNotEmpty &&
                    int.tryParse(_umurController.text) != null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthDropdownField(
                label: 'Gender',
                value: _gender,
                items: _genderOptions,
                onChanged: (v) => setState(() => _gender = v ?? _gender),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthDropdownField(
          label: 'Pendidikan',
          value: _pendidikan,
          items: _pendidikanOptions,
          onChanged: (v) => setState(() => _pendidikan = v ?? _pendidikan),
        ),
        const SizedBox(height: 16),
        AuthDropdownField(
          label: 'Region',
          value: _region,
          items: _regionOptions,
          onChanged: (v) => setState(() => _region = v ?? _region),
        ),
      ],
    );
  }

  // ── Tombol Register ────────────────────────────────────────────────────────

  Widget _buildRegisterButton(bool isLoading) {
    final isEnabled = _isFormValid && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isEnabled ? _onRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Daftar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AppColors.textMuted),
              ),
              TextSpan(
                text: 'Masuk',
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
