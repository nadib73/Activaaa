import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

/// Mengelola penyimpanan data lokal menggunakan SharedPreferences.
/// Menyimpan JWT token, expiry time, dan data user dasar.
///
/// JWT Config (dari jwt.php):
/// - ttl         : 60 menit  → token expired 1 jam
/// - refresh_ttl : 20160 menit (2 minggu)
class LocalStorage {
  // ── Keys ───────────────────────────────────────────────────────────────────
  static const _keyToken = 'auth_token';
  static const _keyTokenExpiry = 'auth_token_expiry'; // timestamp expired
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyIsLoggedIn = 'is_logged_in';

  // ── Token ──────────────────────────────────────────────────────────────────

  /// Simpan JWT token + hitung waktu expired (ttl = 60 menit dari jwt.php)
  Future<void> saveToken(String token, {int ttlMinutes = 60}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now()
        .add(Duration(minutes: ttlMinutes))
        .millisecondsSinceEpoch;
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyTokenExpiry, expiry);
  }

  /// Ambil JWT token. Return null jika belum ada.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Cek apakah token sudah expired berdasarkan TTL lokal
  /// (sebagai early check sebelum hit server)
  Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_keyTokenExpiry);
    if (expiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  /// Sisa waktu token dalam menit (untuk keperluan debug)
  Future<int> tokenRemainingMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_keyTokenExpiry);
    if (expiry == null) return 0;
    final remaining = expiry - DateTime.now().millisecondsSinceEpoch;
    return remaining > 0 ? (remaining / 60000).floor() : 0;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyTokenExpiry);
  }

  // ── User Data ──────────────────────────────────────────────────────────────

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

  Future<String?> getUserId() async =>
      (await SharedPreferences.getInstance()).getString(_keyUserId);
  Future<String?> getUserName() async =>
      (await SharedPreferences.getInstance()).getString(_keyUserName);
  Future<String?> getUserEmail() async =>
      (await SharedPreferences.getInstance()).getString(_keyUserEmail);

  /// Cek apakah user sudah login (ada token & flag login)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    return loggedIn && token != null && token.isNotEmpty;
  }

  // ── Clear All ──────────────────────────────────────────────────────────────

  /// Hapus semua data lokal (dipanggil saat logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
