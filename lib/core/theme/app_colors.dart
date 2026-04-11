import 'package:flutter/material.dart';

/// Semua konstanta warna aplikasi DigitalLife Analyzer.
class AppColors {
  AppColors._();

  // ── Background ─────────────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0F1C2E);
  static const Color bgCard = Color(0xFF1A2D42);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // ── Brand / Primary ────────────────────────────────────────────────────────
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0F766E);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ── Border ─────────────────────────────────────────────────────────────────
  static const Color cardBorder = Color(0xFF263D57);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ── Overlay (const, tanpa withOpacity) ────────────────────────────────────
  static const Color tealOverlay = Color(0x1F0D9488); // teal ~12%
  static const Color redOverlay = Color(0x1FEF4444); // red  ~12%
  static const Color amberOverlay = Color(0x1FF59E0B); // amber ~12%
  static const Color blueOverlay = Color(0x1F3B82F6); // blue ~12%
}
