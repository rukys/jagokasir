/// Sealed class Failure — digunakan di semua usecase & repository.
/// Semua error yang surface ke presentation layer harus berupa subclass Failure.
sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Error operasi database SQLite.
final class DbFailure extends Failure {
  const DbFailure(super.message);
}

/// Error validasi input bisnis (dilakukan di usecase layer).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Data yang dicari tidak ditemukan di database.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Aksi tidak diizinkan karena role/permission tidak cukup.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Error terkait operasi file (backup, restore, export).
final class FileFailure extends Failure {
  const FileFailure(super.message);
}

/// Error terkait printer (koneksi, print).
final class PrinterFailure extends Failure {
  const PrinterFailure(super.message);
}

/// Error umum yang tidak terklasifikasi.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
