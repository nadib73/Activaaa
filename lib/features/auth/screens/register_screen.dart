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

  String _gender = 'Laki-laki';
  String _pendidikan = 'Sarjana';
  String _region = 'Asia';
  DateTime? _tglLahir;
  String _dailyRole = 'Pelajar/Mahasiswa';
  String _incomeLevel = 'Rendah';

  static const _genderOptions = ['Laki-laki', 'Perempuan'];
  static const _pendidikanOptions = [
    'SMA/SMK/Sederajat',
    'Sarjana',
    'Magister',
    'Doktor',
  ];
  static const _regionOptions = [
    'Afrika',
    'Asia',
    'Eropa',
    'Timur Tengah',
    'Amerika Utara',
    'Amerika Selatan',
  ];
  static const _roleOptions = [
    'Pelajar/Mahasiswa',
    'Karyawan Penuh waktu',
    'Karyawan Paruh waktu',
    'Pengurus rumah tangga',
    'Tidak bekerja/sedang mencari kerja',
  ];
  static const _incomeOptions = [
    'Rendah',
    'Menengah Bawah',
    'Menengah Atas',
    'Tinggi',
  ];

  // ── Validation state ────────────────────────────────────────────────────
  bool _submitted = false;
  String? _namaError;
  String? _emailError;
  String? _passwordError;
  String? _konfirmasiError;
  String? _tglLahirError;

  // ── Manual email entry (when Google is not used) ────────────────────────
  final _manualEmailController = TextEditingController();

  // ── Google Sign-In verification ─────────────────────────────────────────
  bool _googleVerified = false;
  bool _googleLoading = false;
  String? _googleError;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        '1015245613521-m6fice524tsb1ufv7je101m9n04rdlem.apps.googleusercontent.com', // Web OAuth Client ID
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
    _manualEmailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
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
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Nama tidak boleh mengandung angka';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Harus mengandung huruf besar';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Harus mengandung huruf kecil';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Harus mengandung angka';
    return null;
  }

  String? _validateKonfirmasi(String value) {
    if (value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != _passwordController.text) return 'Password tidak cocok';
    return null;
  }

  String? _validateTglLahir() {
    if (_tglLahir == null) return 'Tanggal lahir wajib diisi';
    final age = DateTime.now().difference(_tglLahir!).inDays ~/ 365;
    if (age < 10 || age > 120) return 'Umur harus antara 10–120 tahun';
    return null;
  }

  int get _ageFromBirthdate {
    if (_tglLahir == null) return 0;
    return DateTime.now().difference(_tglLahir!).inDays ~/ 365;
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

  // ── Computed validity (for green check icons) ──────────────────────────

  bool get _namaValid =>
      _namaController.text.trim().length >= 3 &&
      !RegExp(r'[0-9]').hasMatch(_namaController.text.trim());

  bool get _passValid => _validatePassword(_passwordController.text) == null;

  bool get _konfirmasiValid =>
      _konfirmasiController.text.isNotEmpty &&
      _konfirmasiController.text == _passwordController.text &&
      _passValid;

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _onRegister() async {
    final nama = _namaController.text.trim();
    // Use Google-verified email if available, otherwise use manual email
    final email = _googleVerified
        ? _emailController.text.trim()
        : _manualEmailController.text.trim();
    final password = _passwordController.text;
    final konfirmasi = _konfirmasiController.text;
    final umur = _ageFromBirthdate;

    // Sync manual email to main controller if not Google-verified
    if (!_googleVerified) {
      _emailController.text = _manualEmailController.text.trim();
    }

    // Mark as submitted → show all errors
    setState(() {
      _submitted = true;
      _namaError = _validateNama(nama);
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
      _konfirmasiError = _validateKonfirmasi(konfirmasi);
      _tglLahirError = _validateTglLahir();
    });

    // If any errors, shake & vibrate
    final hasError =
        _namaError != null ||
        _emailError != null ||
        _passwordError != null ||
        _konfirmasiError != null ||
        _tglLahirError != null;

    if (hasError) {
      _shakeController.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }
    // Clear error sebelumnya
    ref.read(authProvider.notifier).clearError();

    // Mapping: UI (Indo) -> DB (English)
    final genderMap = {'Laki-laki': 'Male', 'Perempuan': 'Female'};
    final regionMap = {
      'Afrika': 'Africa',
      'Asia': 'Asia',
      'Eropa': 'Europe',
      'Timur Tengah': 'Middle East',
      'Amerika Utara': 'North America',
      'Amerika Selatan': 'South America',
    };
    final eduMap = {
      'SMA/SMK/Sederajat': 'High School',
      'Sarjana': 'Bachelor',
      'Magister': 'Master',
      'Doktor': 'PhD',
    };
    final incomeLevelMap = {
      'Rendah': 'Low',
      'Menengah Bawah': 'Lower-Mid',
      'Menengah Atas': 'Upper-Mid',
      'Tinggi': 'High',
    };
    final roleMap = {
      'Pelajar/Mahasiswa': 'Student',
      'Karyawan Penuh waktu': 'Full-time',
      'Karyawan Paruh waktu': 'Part-time',
      'Pengurus rumah tangga': 'Caregiver',
      'Tidak bekerja/sedang mencari kerja': 'Unemployed',
    };

    final mappedGender = genderMap[_gender] ?? 'Male';
    final mappedRegion = regionMap[_region] ?? 'Asia';
    final mappedEdu = eduMap[_pendidikan] ?? 'Bachelor';
    final mappedIncome = incomeLevelMap[_incomeLevel] ?? 'Low';
    final mappedRole = roleMap[_dailyRole] ?? 'Student';

    bool success = false;
    if (_useMockRegister) {
      success = await ref
          .read(authProvider.notifier)
          .mockRegister(
            name: nama,
            email: email,
            gender: mappedGender,
            educationLevel: mappedEdu,
            region: mappedRegion,
            dateOfBirth: _tglLahir,
            dailyRole: mappedRole,
            incomeLevel: mappedIncome,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .register(
            name: nama,
            email: email,
            password: password,
            passwordConfirmation: konfirmasi,
            gender: mappedGender,
            educationLevel: mappedEdu,
            region: mappedRegion,
            dateOfBirth: _tglLahir,
            dailyRole: mappedRole,
            incomeLevel: mappedIncome,
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
                'Opsional — verifikasi dengan Google\natau isi email secara manual di bawah',
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
      ],
    );
  }

  // ── Informasi Akun ─────────────────────────────────────────────────────

  void _onManualEmailChanged(String val) {
    setState(() {
      if (_submitted) _emailError = _validateEmail(val.trim());
    });
    ref.read(authProvider.notifier).clearError();
  }

  bool get _manualEmailValid =>
      _emailRegex.hasMatch(_manualEmailController.text.trim());

  Widget _buildInfoAkunSection() {
    return Column(
      children: [
        // ── Google Verification Button (optional) ───────────────────────
        _buildGoogleVerifySection(),
        const SizedBox(height: 16),
        // ── Manual email field (shown when Google is not verified) ──────
        if (!_googleVerified) ...[
          AuthTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _manualEmailController,
            keyboardType: TextInputType.emailAddress,
            isValid: _manualEmailValid,
            errorText: _emailError,
            onChanged: _onManualEmailChanged,
          ),
          const SizedBox(height: 16),
        ],
        AuthTextField(
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
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
        // Tgl Lahir (picker)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggal Lahir',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _tglLahir ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.teal,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _tglLahir = picked;
                    _tglLahirError = null;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _tglLahirError != null
                        ? AppColors.red
                        : (_tglLahir != null
                              ? AppColors.teal
                              : Colors.grey.shade200),
                    width: (_tglLahir != null || _tglLahirError != null)
                        ? 1.5
                        : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      color: _tglLahir != null
                          ? AppColors.teal
                          : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _tglLahir != null
                          ? '${_tglLahir!.day.toString().padLeft(2, '0')} / '
                                '${_tglLahir!.month.toString().padLeft(2, '0')} / '
                                '${_tglLahir!.year}'
                          : 'DD / MM / YYYY',
                      style: TextStyle(
                        color: _tglLahir != null
                            ? AppColors.textDark
                            : Colors.grey.shade400,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (_tglLahir != null) ...[
                      Text(
                        '$_ageFromBirthdate tahun',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.teal,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_tglLahirError != null)
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
                      _tglLahirError!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Gender
        AuthDropdownField(
          label: 'Gender',
          value: _gender,
          items: _genderOptions,
          onChanged: (v) => setState(() => _gender = v ?? _gender),
        ),
        const SizedBox(height: 16),

        // Pendidikan
        AuthDropdownField(
          label: 'Pendidikan',
          value: _pendidikan,
          items: _pendidikanOptions,
          onChanged: (v) => setState(() => _pendidikan = v ?? _pendidikan),
        ),
        const SizedBox(height: 16),

        // Daily Role  ← BARU
        AuthDropdownField(
          label: 'Peran Sehari-hari',
          value: _dailyRole,
          items: _roleOptions,
          onChanged: (v) => setState(() => _dailyRole = v ?? _dailyRole),
        ),
        const SizedBox(height: 16),

        // Income Level ← BARU
        AuthDropdownField(
          label: 'Tingkat Pendapatan',
          value: _incomeLevel,
          items: _incomeOptions,
          onChanged: (v) => setState(() => _incomeLevel = v ?? _incomeLevel),
        ),
        const SizedBox(height: 16),

        // Region
        AuthDropdownField(
          label: 'Wilayah/Tempat Tinggal',
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
