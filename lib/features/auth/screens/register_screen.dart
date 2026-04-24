import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
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

  // ── Validation state ────────────────────────────────────────────────────
  bool _submitted = false;
  String? _namaError;
  String? _emailError;
  String? _passwordError;
  String? _konfirmasiError;
  String? _umurError;

  // ── Google Sign-In verification ─────────────────────────────────────────
  bool _googleVerified = false;
  bool _googleLoading = false;
  String? _googleError;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '1015245613521-m6fice524tsb1ufv7je101m9n04rdlem.apps.googleusercontent.com',
  );

  // ── Shake animation ─────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _umurController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Google Sign-In Verification ────────────────────────────────────────

  Future<void> _verifyWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _googleError = null;
    });

    try {
      // Sign out dulu agar selalu muncul account picker
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();

      if (account != null) {
        setState(() {
          _googleVerified = true;
          _emailController.text = account.email;
          _namaController.text = account.displayName ?? _namaController.text;
          _emailError = null;
          _namaError = null;
        });
        HapticFeedback.mediumImpact();
      } else {
        setState(() {
          _googleError = 'Verifikasi dibatalkan';
        });
      }
    } catch (e) {
      setState(() {
        _googleError = 'Gagal verifikasi Google. Coba lagi.';
      });
    } finally {
      setState(() => _googleLoading = false);
    }
  }

  // ── Validators ─────────────────────────────────────────────────────────

  String? _validateNama(String value) {
    if (value.isEmpty) return 'Nama lengkap wajib diisi';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    if (RegExp(r'[0-9]').hasMatch(value))
      return 'Nama tidak boleh mengandung angka';
    return null;
  }

  String? _validateEmail(String value) {
    if (!_googleVerified) return 'Email harus diverifikasi dengan Google';
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Harus mengandung huruf besar';
    if (!RegExp(r'[a-z]').hasMatch(value))
      return 'Harus mengandung huruf kecil';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Harus mengandung angka';
    return null;
  }

  String? _validateKonfirmasi(String value) {
    if (value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != _passwordController.text) return 'Password tidak cocok';
    return null;
  }

  String? _validateUmur(String value) {
    if (value.isEmpty) return 'Umur wajib diisi';
    final age = int.tryParse(value);
    if (age == null) return 'Masukkan angka yang valid';
    if (age < 10 || age > 120) return 'Umur harus antara 10-120';
    return null;
  }

  // ── onChanged handlers ─────────────────────────────────────────────────

  void _onNamaChanged(String val) {
    setState(() {
      if (_submitted) _namaError = _validateNama(val.trim());
    });
    ref.read(authProvider.notifier).clearError();
  }

  void _onPasswordChanged(String val) {
    setState(() {
      if (_submitted) {
        _passwordError = _validatePassword(val);
        // Re-validate konfirmasi jika sudah diisi
        if (_konfirmasiController.text.isNotEmpty) {
          _konfirmasiError = _validateKonfirmasi(_konfirmasiController.text);
        }
      }
    });
    ref.read(authProvider.notifier).clearError();
  }

  void _onKonfirmasiChanged(String val) {
    setState(() {
      if (_submitted) _konfirmasiError = _validateKonfirmasi(val);
    });
    ref.read(authProvider.notifier).clearError();
  }

  void _onUmurChanged(String val) {
    setState(() {
      if (_submitted) _umurError = _validateUmur(val.trim());
    });
    ref.read(authProvider.notifier).clearError();
  }

  // ── Computed validity (for green check icons) ──────────────────────────

  bool get _namaValid =>
      _namaController.text.trim().length >= 3 &&
      !RegExp(r'[0-9]').hasMatch(_namaController.text.trim());

  bool get _passValid => _validatePassword(_passwordController.text) == null;

  bool get _konfirmasiValid =>
      _konfirmasiController.text.isNotEmpty &&
      _konfirmasiController.text == _passwordController.text &&
      _passValid;

  bool get _umurValid {
    final age = int.tryParse(_umurController.text);
    return age != null && age >= 10 && age <= 120;
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _onRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final konfirmasi = _konfirmasiController.text;
    final umur = _umurController.text.trim();

    // Mark as submitted → show all errors
    setState(() {
      _submitted = true;
      _namaError = _validateNama(nama);
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
      _konfirmasiError = _validateKonfirmasi(konfirmasi);
      _umurError = _validateUmur(umur);
    });

    // If any errors, shake & vibrate
    final hasError =
        _namaError != null ||
        _emailError != null ||
        _passwordError != null ||
        _konfirmasiError != null ||
        _umurError != null;

    if (hasError) {
      _shakeController.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    // Clear error sebelumnya
    ref.read(authProvider.notifier).clearError();

    bool success = false;
    if (_useMockRegister) {
      success = await ref
          .read(authProvider.notifier)
          .mockRegister(
            name: nama,
            email: email,
            age: int.parse(umur),
            gender: _gender,
            educationLevel: _pendidikan,
            region: _region,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .register(
            name: nama,
            email: email,
            password: password,
            passwordConfirmation: konfirmasi,
            age: int.parse(umur),
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

  // ── Build ──────────────────────────────────────────────────────────────

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
                    const SizedBox(height: 12),
                    _buildPasswordHint(),
                    const SizedBox(height: 20),
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

  // ── Header ─────────────────────────────────────────────────────────────

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

  // ── Google Verify Section ──────────────────────────────────────────────

  Widget _buildGoogleVerifySection() {
    if (_googleVerified) {
      // ── Verified state: show email locked with badge ─────────────────
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.teal,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun Google Terverifikasi',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _emailController.text,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _verifyWithGoogle,
              child: const Text(
                'Ganti',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Unverified state: show verify button ─────────────────────────────
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _googleError != null
                  ? AppColors.red.withValues(alpha: 0.4)
                  : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.textMuted,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifikasi Akun Google',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hanya akun Google yang terdaftar\nyang bisa melakukan registrasi',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _googleLoading ? null : _verifyWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: Text(
                    _googleLoading
                        ? 'Memverifikasi...'
                        : 'Verifikasi dengan Google',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.bgDark.withValues(
                      alpha: 0.7,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error message
        if (_googleError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _googleError!,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        // Submitted but not verified
        if (_submitted && !_googleVerified && _googleError == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Email harus diverifikasi dengan Google',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Informasi Akun ─────────────────────────────────────────────────────

  Widget _buildInfoAkunSection() {
    return Column(
      children: [
        // ── Google Verification Button ──────────────────────────────────
        _buildGoogleVerifySection(),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Nama Lengkap',
          hint: _googleVerified ? '' : 'Verifikasi Google dulu',
          prefixIcon: Icons.person_outline_rounded,
          controller: _namaController,
          isValid: _namaValid,
          errorText: _namaError,
          onChanged: _onNamaChanged,
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
                isValid: _passValid,
                errorText: _passwordError,
                onChanged: _onPasswordChanged,
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
                isValid: _konfirmasiValid,
                errorText: _konfirmasiError,
                onChanged: _onKonfirmasiChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Data Diri ──────────────────────────────────────────────────────────

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
                isValid: _umurValid,
                errorText: _umurError,
                onChanged: _onUmurChanged,
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

  // ── Password Hint ──────────────────────────────────────────────────────

  Widget _buildPasswordHint() {
    final pass = _passwordController.text;
    final hasLength = pass.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pass);
    final hasLower = RegExp(r'[a-z]').hasMatch(pass);
    final hasDigit = RegExp(r'[0-9]').hasMatch(pass);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: pass.isEmpty
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat Password:',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRule('Minimal 8 karakter', hasLength),
                  const SizedBox(height: 4),
                  _buildPasswordRule('Mengandung huruf besar (A-Z)', hasUpper),
                  const SizedBox(height: 4),
                  _buildPasswordRule('Mengandung huruf kecil (a-z)', hasLower),
                  const SizedBox(height: 4),
                  _buildPasswordRule('Mengandung angka (0-9)', hasDigit),
                ],
              ),
            ),
    );
  }

  Widget _buildPasswordRule(String text, bool met) {
    return Row(
      children: [
        Icon(
          met
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: met ? AppColors.teal : AppColors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: met ? AppColors.teal : AppColors.textMuted,
            fontSize: 12,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Tombol Register ────────────────────────────────────────────────────

  Widget _buildRegisterButton(bool isLoading) {
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
          onPressed: isLoading ? null : _onRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
            disabledForegroundColor: Colors.white70,
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
                      'Mendaftarkan...',
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
                    Icon(Icons.person_add_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
