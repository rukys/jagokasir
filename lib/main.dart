import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek restore flag untuk pemulihan otomatis (safety-net) jika interupsi terjadi
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final flagFile = File(p.join(appDocDir.path, 'restore_in_progress.flag'));
    if (await flagFile.exists()) {
      final safetyNetPath = await flagFile.readAsString();
      if (safetyNetPath.isNotEmpty && File(safetyNetPath).existsSync()) {
        final safetyBytes = await File(safetyNetPath).readAsBytes();
        final safetyArchive = ZipDecoder().decodeBytes(safetyBytes);
        
        ArchiveFile? safetyDbArchive;
        for (final archFile in safetyArchive) {
          if (archFile.name == 'pos_kasir.db') {
            safetyDbArchive = archFile;
            break;
          }
        }
        
        if (safetyDbArchive != null) {
          final dbPath = p.join(await getDatabasesPath(), 'pos_kasir.db');
          final activeDbFile = File(dbPath);
          if (await activeDbFile.exists()) {
            await activeDbFile.delete();
          }
          await activeDbFile.writeAsBytes(safetyDbArchive.content as List<int>);
        }
      }
      // Hapus flag setelah pemulihan sukses
      await flagFile.delete();
    }
  } catch (e) {
    debugPrint('Gagal melakukan pemulihan otomatis pada startup: $e');
  }

  // Paksa orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android: dark icons
      statusBarBrightness: Brightness.light,    // iOS: dark icons/text
    ),
  );

  runApp(
    const ProviderScope(
      child: PosKasirApp(),
    ),
  );
}
