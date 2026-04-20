import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk LocalStorage.
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

/// Mengelola penyimpanan data lokal menggunakan SharedPreferences.
/// Digunakan untuk menyimpan JWT token dan data user yang sederhana.
class LocalStorage {
  // ── Keys ───────────────────────────────────────────────────────────────────
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // ── Token ──────────────────────────────────────────────────────────────────

  /// Simpan JWT token setelah login/register berhasil.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Ambil JWT token yang tersimpan.
  /// Return null jika belum login.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Hapus token saat logout.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // ── User Data ──────────────────────────────────────────────────────────────

  /// Simpan data user dasar setelah login.
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Ambil user ID yang tersimpan.
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Ambil nama user yang tersimpan.
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Ambil email user yang tersimpan.
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Cek apakah user sudah login.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    return loggedIn && token != null;
  }

  // ── Clear All ──────────────────────────────────────────────────────────────

  /// Hapus semua data lokal saat logout.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
