import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScannerListener extends StatefulWidget {
  const BarcodeScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
  });

  final Widget child;
  final ValueChanged<String> onBarcodeScanned;

  @override
  State<BarcodeScannerListener> createState() => _BarcodeScannerListenerState();
}

class _BarcodeScannerListenerState extends State<BarcodeScannerListener> {
  final List<String> _buffer = [];
  DateTime? _lastKeystrokeTime;

  // Jeda maksimum antar-keystroke dari barcode scanner fisik (sangat cepat, biasanya < 30ms)
  static const Duration _maxKeystrokeInterval = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    super.dispose();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    final now = DateTime.now();

    // Hitung interval sejak keystroke terakhir
    final lastTime = _lastKeystrokeTime;
    final interval = lastTime != null ? now.difference(lastTime) : null;
    _lastKeystrokeTime = now;

    // Jika jeda terlalu lama, anggap ini ketukan manusia baru dan bersihkan buffer lama
    if (interval != null && interval > _maxKeystrokeInterval) {
      _buffer.clear();
    }

    // Jika tombol Enter ditekan
    if (key == LogicalKeyboardKey.enter) {
      if (_buffer.isNotEmpty) {
        final barcode = _buffer.join().trim();
        _buffer.clear();
        if (barcode.length >= 3) {
          // Panggil callback secara asinkron agar tidak memblokir event loop
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onBarcodeScanned(barcode);
          });
          // Consume event Enter agar tidak men-submit form/action lain di UI
          return true;
        }
      }
      return false;
    }

    // Baca karakter yang dihasilkan
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      // Validasi karakter alphanumeric
      final regex = RegExp(r'[a-zA-Z0-9]');
      if (regex.hasMatch(char)) {
        _buffer.add(char);
        // Jika ini adalah kelanjutan dari sequence cepat, kita consume event-nya
        // agar tidak diketikkan ke dalam TextField yang sedang fokus.
        if (interval != null && interval <= _maxKeystrokeInterval) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
