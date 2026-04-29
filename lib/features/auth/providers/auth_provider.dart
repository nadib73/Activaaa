import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user = null,
    this.errorMessage = null,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AuthState()) {
    _checkLoginStatus();
  }

  // ── Check status saat app dibuka ───────────────────────────────────────────
  Future<void> _checkLoginStatus() async {
    final loggedIn = await _service.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _service.getProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        // Token expired / server mati → tetap unauthenticated
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // ── Login (Real API) ───────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _service.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Register (Real API) ────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required String educationLevel,
    required String region,
    DateTime? dateOfBirth,
    String? dailyRole,
    String? incomeLevel,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _service.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        gender: gender,
        educationLevel: educationLevel,
        region: region,
        dateOfBirth: dateOfBirth,
        dailyRole: dailyRole,
        incomeLevel: incomeLevel,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Mock Login (sementara sebelum backend bisa diakses) ───────────────────
  Future<bool> mockLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1));

    const mockAccounts = {
      'rizky@gmail.com': '123456',
      'test@test.com': 'password',
      'admin@gmail.com': 'admin123',
    };

    if (mockAccounts[email.trim().toLowerCase()] == password) {
      final mockUser = UserModel(
        id: 'mock_001',
        name: _nameFromEmail(email),
        email: email.trim().toLowerCase(),
        gender: 'Male',
        dateOfBirth: DateTime(2005, 1, 1),
        age: 21,
        region: 'Asia',
        educationLevel: 'Bachelor',
        dailyRole: 'Student',
        incomeLevel: 'Low',
        createdAt: DateTime.now(),
      );
      await _service.saveMockSession(mockUser);
      state = AuthState(status: AuthStatus.authenticated, user: mockUser);
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Email atau password salah.',
      );
      return false;
    }
  }

  // ── Mock Register ──────────────────────────────────────────────────────────
  Future<bool> mockRegister({
    required String name,
    required String email,
    required String gender,
    required String educationLevel,
    required String region,
    DateTime? dateOfBirth,
    String? dailyRole,
    String? incomeLevel,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1));

    final mockUser = UserModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.trim().toLowerCase(),
      gender: gender,
      dateOfBirth: dateOfBirth,
      age: dateOfBirth != null
          ? DateTime.now().difference(dateOfBirth).inDays ~/ 365
          : 20,
      region: region,
      educationLevel: educationLevel,
      dailyRole: dailyRole ?? 'Student',
      incomeLevel: incomeLevel ?? 'Low',
      createdAt: DateTime.now(),
    );
    await _service.saveMockSession(mockUser);
    state = AuthState(status: AuthStatus.authenticated, user: mockUser);
    return true;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _service.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ── Clear Error ────────────────────────────────────────────────────────────
  void clearError() {
    state = AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
      user: state.user,
    );
  }

  String _nameFromEmail(String email) {
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
