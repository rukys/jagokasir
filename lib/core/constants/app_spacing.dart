/// Token spacing & sizing resmi POS Kasir.
/// Selalu pakai konstanta ini — jangan hardcode angka di widget.
class AppSpacing {
  AppSpacing._();

  // ── Base spacing (unit: 4px) ──────────────────────────────────────────────
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  // ── Page padding ──────────────────────────────────────────────────────────
  /// Gunakan: `EdgeInsets.all(AppSpacing.pagePadding)`
  static const double pagePadding = 16.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 24.0;
  static const double radiusFull = 999.0; // pill / chip

  // ── Elevation (Material 3) ────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm   = 1.0;
  static const double elevationMd   = 3.0;
  static const double elevationLg   = 6.0;

  // ── Component sizing ──────────────────────────────────────────────────────
  static const double buttonHeight    = 48.0;
  static const double inputHeight     = 56.0;
  static const double appBarHeight    = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double fabSize         = 56.0;

  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;

  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 40.0;
  static const double avatarSizeLg = 56.0;

  static const double productCardWidth = 160.0;
  static const double productImageSize = 100.0;
}
