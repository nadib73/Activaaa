import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_dropdown_field.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// Ganti false saat backend siap
const bool _useMockRegister = true;

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

  // ── Field tambahan sesuai revisi ──────────────────────────────────────────
  String _gender = 'Male';
  String _region = 'Asia';
  String _educationLevel = 'High School';
  String _incomeLevel = 'Low';
  String _dailyRole = 'Student';
  String _deviceType = 'Android';

  // ── Options ───────────────────────────────────────────────────────────────
  static const _genderOptions = ['Male', 'Female'];

  static const _regionOptions = [
    'Africa',
    'Asia',
    'Europe',
    'Middle East',
    'North America',
    'Oceania',
    'South America',
  ];

  static const _educationOptions = [
    'High School',
    'Diploma',
    'Bachelor',
    'Master',
    'PhD',
  ];

  static const _incomeOptions = ['Low', 'Lower-Mid', 'Upper-Mid', 'High'];

  static const _roleOptions = [
    'Student',
    'Full-time Employee',
    'Part-time Employee',
    'Freelancer',
    'Caregiver',
    'Unemployed',
  ];

  static const _deviceOptions = ['Android', 'iPhone', 'Laptop/PC', 'Tablet'];

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
    final age = int.tryParse(_umurController.text) ?? 0;
    return _namaController.text.trim().isNotEmpty &&
        _emailController.text.contains('@') &&
        _emailController.text.contains('.') &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _konfirmasiController.text &&
        age >= 13 &&
        age <= 50;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _onRegister() async {
    if (!_isFormValid) return;

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
            educationLevel: _educationLevel,
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
            educationLevel: _educationLevel,
            region: _region,
          );
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
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMsg != null) ...[
                      AuthErrorBanner(message: errorMsg),
                      const SizedBox(height: 16),
                    ],

                    // ── BAGIAN 1: Akun ───────────────────────────────────
                    _buildSectionLabel('INFORMASI AKUN'),
                    const SizedBox(height: 14),
                    _buildInfoAkunSection(),
                    const SizedBox(height: 24),

                    // ── BAGIAN 2: Data Diri ───────────────────────────────
                    _buildSectionLabel('DATA DIRI'),
                    const SizedBox(height: 14),
                    _buildDataDiriSection(),
                    const SizedBox(height: 24),

                    // ── BAGIAN 3: Kebiasaan Digital ───────────────────────
                    _buildSectionLabel('KEBIASAAN DIGITAL'),
                    const SizedBox(height: 6),
                    _buildSectionSubLabel(
                      'Digunakan untuk personalisasi analisis ML kamu',
                    ),
                    const SizedBox(height: 14),
                    _buildKebiasaanDigitalSection(),
                    const SizedBox(height: 28),

                    // ── Tombol Daftar ─────────────────────────────────────
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

  // ── Section Label ──────────────────────────────────────────────────────────

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

  Widget _buildSectionSubLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        height: 1.4,
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
        const SizedBox(height: 14),
        AuthTextField(
          label: 'Email',
          hint: 'nama@email.com',
          prefixIcon: Icons.mail_outline_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          isValid: _emailController.text.contains('@'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Password',
                hint: 'Min. 8 karakter',
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
                hint: 'Ulangi password',
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
                hint: '20',
                prefixIcon: Icons.cake_outlined,
                controller: _umurController,
                keyboardType: TextInputType.number,
                isValid: () {
                  final age = int.tryParse(_umurController.text) ?? 0;
                  return age >= 13 && age <= 50;
                }(),
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
        const SizedBox(height: 14),
        AuthDropdownField(
          label: 'Region / Wilayah',
          value: _region,
          items: _regionOptions,
          onChanged: (v) => setState(() => _region = v ?? _region),
        ),
        const SizedBox(height: 14),
        AuthDropdownField(
          label: 'Pendidikan Terakhir',
          value: _educationLevel,
          items: _educationOptions,
          onChanged: (v) =>
              setState(() => _educationLevel = v ?? _educationLevel),
        ),
        const SizedBox(height: 14),
        AuthDropdownField(
          label: 'Tingkat Pendapatan',
          value: _incomeLevel,
          items: _incomeOptions,
          onChanged: (v) => setState(() => _incomeLevel = v ?? _incomeLevel),
        ),
      ],
    );
  }

  // ── Kebiasaan Digital ──────────────────────────────────────────────────────

  Widget _buildKebiasaanDigitalSection() {
    return Column(
      children: [
        AuthDropdownField(
          label: 'Peran Sehari-hari',
          value: _dailyRole,
          items: _roleOptions,
          onChanged: (v) => setState(() => _dailyRole = v ?? _dailyRole),
        ),
        const SizedBox(height: 14),
        AuthDropdownField(
          label: 'Perangkat Utama yang Dipakai',
          value: _deviceType,
          items: _deviceOptions,
          onChanged: (v) => setState(() => _deviceType = v ?? _deviceType),
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
