// Exceptions internal yang digunakan di data layer.
// JANGAN expose ke domain atau presentation — konversi ke [Failure] di repository.

/// Exception dari operasi SQLite.
class DbException implements Exception {
  final String message;
  final Object? cause;

  const DbException(this.message, {this.cause});

  @override
  String toString() => 'DbException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Data tidak ditemukan di database.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Pelanggaran constraint database (unique, foreign key, check).
class ConstraintException implements Exception {
  final String message;

  const ConstraintException(this.message);

  @override
  String toString() => 'ConstraintException: $message';
}

/// Exception dari operasi file (baca/tulis).
class FileException implements Exception {
  final String message;
  final Object? cause;

  const FileException(this.message, {this.cause});

  @override
  String toString() => 'FileException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Exception dari koneksi atau operasi printer.
class PrinterException implements Exception {
  final String message;

  const PrinterException(this.message);

  @override
  String toString() => 'PrinterException: $message';
}
