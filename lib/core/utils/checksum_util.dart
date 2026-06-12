import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Utilitas checksum file database untuk verifikasi integritas backup.
class ChecksumUtil {
  ChecksumUtil._();

  /// Hitung SHA-256 checksum dari file.
  /// Return string hex 64 karakter.
  /// Throw [FileSystemException] jika file tidak ada.
  static Future<String> computeFileChecksum(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File tidak ditemukan', filePath);
    }

    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hitung SHA-256 checksum dari bytes langsung.
  static String computeBytesChecksum(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi checksum file cocok dengan expected.
  static Future<bool> verifyFileChecksum(
    String filePath,
    String expectedChecksum,
  ) async {
    try {
      final actual = await computeFileChecksum(filePath);
      return actual == expectedChecksum;
    } on FileSystemException {
      return false;
    }
  }

  /// Hitung checksum dari string (untuk verifikasi data kecil).
  static String computeStringChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
