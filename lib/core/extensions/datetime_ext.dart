/// Extension DateTime untuk format tampilan dan utilitas.
extension DateTimeExt on DateTime {
  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const List<String> _monthNamesFull = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// Format ke "10 Jun 2024"
  String toDisplayDate() {
    final m = _monthNames[month - 1];
    return '$day $m $year';
  }

  /// Format ke "10 Juni 2024"
  String toDisplayDateFull() {
    final m = _monthNamesFull[month - 1];
    return '$day $m $year';
  }

  /// Format ke "10 Jun 2024, 14:30"
  String toDisplayDateTime() {
    final m = _monthNames[month - 1];
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    return '$day $m $year, $h:$min';
  }

  /// Format ke "14:30" (jam:menit)
  String toDisplayTime() {
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    return '$h:$min';
  }

  /// Format ke "Jun 2024" (untuk header laporan bulanan)
  String toDisplayMonthYear() {
    final m = _monthNames[month - 1];
    return '$m $year';
  }

  /// Alias toIso8601String() untuk konsistensi.
  String toIso() => toIso8601String();

  /// Cek apakah tanggal sama (abaikan waktu).
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Start of day: set jam ke 00:00:00.000
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day: set jam ke 23:59:59.999
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Apakah hari ini?
  bool get isToday => isSameDay(DateTime.now());
}
