import 'package:uuid/uuid.dart';

/// Wrapper generator UUID v4.
/// Dipakai di semua datasource sebagai primary key tabel.
class UuidGenerator {
  UuidGenerator._();

  static const _uuid = Uuid();

  /// Generate UUID v4 string.
  /// Contoh: `550e8400-e29b-41d4-a716-446655440000`
  static String generate() => _uuid.v4();
}
