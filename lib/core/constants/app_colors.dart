import 'package:flutter/material.dart';

/// Palet warna resmi POS Kasir.
/// Selalu pakai konstanta ini — jangan hardcode hex di widget.
class AppColors {
  AppColors._();

  // ── Primary (Hijau Sage — soft, tidak menyilaukan) ────────────────────────
  static const primary             = Color(0xFF2E7D52);
  static const onPrimary           = Color(0xFFFFFFFF);
  static const primaryContainer    = Color(0xFFB7F0CE);
  static const onPrimaryContainer  = Color(0xFF00391A);

  // ── Secondary (Teal muted) ────────────────────────────────────────────────
  static const secondary              = Color(0xFF4C8577);
  static const onSecondary            = Color(0xFFFFFFFF);
  static const secondaryContainer     = Color(0xFFCEEAE1);
  static const onSecondaryContainer   = Color(0xFF082019);

  // ── Tertiary (Amber — highlight & aksi penting) ───────────────────────────
  static const tertiary              = Color(0xFF7C5800);
  static const onTertiary            = Color(0xFFFFFFFF);
  static const tertiaryContainer     = Color(0xFFFFDEA0);
  static const onTertiaryContainer   = Color(0xFF271900);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const error             = Color(0xFFBA1A1A);
  static const onError           = Color(0xFFFFFFFF);
  static const errorContainer    = Color(0xFFFFDAD6);
  static const onErrorContainer  = Color(0xFF410002);

  // ── Neutral (Surface & Background) ───────────────────────────────────────
  static const background       = Color(0xFFF6FBF4);
  static const onBackground     = Color(0xFF1A1C1A);
  static const surface          = Color(0xFFFFFFFF);
  static const onSurface        = Color(0xFF1A1C1A);
  static const surfaceVariant   = Color(0xFFDDE5DC);
  static const onSurfaceVariant = Color(0xFF414941);
  static const outline          = Color(0xFF717971);
  static const outlineVariant   = Color(0xFFC1C9BF);

  // ── Status Colors (semantic) ──────────────────────────────────────────────
  static const success      = Color(0xFF2E7D52);
  static const successLight = Color(0xFFB7F0CE);
  static const warning      = Color(0xFF7C5800);
  static const warningLight = Color(0xFFFFDEA0);
  static const danger       = Color(0xFFBA1A1A);
  static const dangerLight  = Color(0xFFFFDAD6);
  static const info         = Color(0xFF4C8577);
  static const infoLight    = Color(0xFFCEEAE1);

  // ── Stock Badge ───────────────────────────────────────────────────────────
  static const stockLow   = Color(0xFFBA1A1A);
  static const stockLowBg = Color(0xFFFFDAD6);
  static const stockOk    = Color(0xFF2E7D52);
  static const stockOkBg  = Color(0xFFB7F0CE);

  // ── Role Badge ────────────────────────────────────────────────────────────
  static const roleOwner    = Color(0xFF7C5800);
  static const roleOwnerBg  = Color(0xFFFFDEA0);
  static const roleAdmin    = Color(0xFF2E7D52);
  static const roleAdminBg  = Color(0xFFB7F0CE);
  static const roleKasir    = Color(0xFF4C8577);
  static const roleKasirBg  = Color(0xFFCEEAE1);
}
