// lib/features/backup/presentation/providers/backup_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/backup_local_datasource.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/entities/backup_history_entity.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/usecases/delete_backup_usecase.dart';
import '../../domain/usecases/get_backup_history_usecase.dart';
import '../../domain/usecases/restore_backup_usecase.dart';
import '../../domain/usecases/share_backup_usecase.dart';
import '../../domain/usecases/validate_backup_file_usecase.dart';

part 'backup_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
BackupLocalDatasource backupLocalDatasource(Ref ref) {
  return const BackupLocalDatasource();
}

@riverpod
BackupRepository backupRepository(Ref ref) {
  return BackupRepositoryImpl(ref.watch(backupLocalDatasourceProvider));
}

@riverpod
CreateBackupUsecase createBackupUsecase(Ref ref) {
  return CreateBackupUsecase(ref.watch(backupRepositoryProvider));
}

@riverpod
DeleteBackupUsecase deleteBackupUsecase(Ref ref) {
  return DeleteBackupUsecase(ref.watch(backupRepositoryProvider));
}

@riverpod
GetBackupHistoryUsecase getBackupHistoryUsecase(Ref ref) {
  return GetBackupHistoryUsecase(ref.watch(backupRepositoryProvider));
}

@riverpod
RestoreBackupUsecase restoreBackupUsecase(Ref ref) {
  return RestoreBackupUsecase(ref.watch(backupRepositoryProvider));
}

@riverpod
ShareBackupUsecase shareBackupUsecase(Ref ref) {
  return ShareBackupUsecase(ref.watch(backupRepositoryProvider));
}

@riverpod
ValidateBackupFileUsecase validateBackupFileUsecase(Ref ref) {
  return ValidateBackupFileUsecase(ref.watch(backupRepositoryProvider));
}

// ── Data Providers ──────────────────────────────────────────────────────────

@riverpod
Future<List<BackupHistoryEntity>> backupHistory(Ref ref) async {
  final usecase = ref.watch(getBackupHistoryUsecaseProvider);
  final result = await usecase();
  return result.fold(
    (failure) => throw failure,
    (history) => history,
  );
}

// ── Notifiers ────────────────────────────────────────────────────────────────

@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  AsyncValue<BackupHistoryEntity?> build() => const AsyncData(null);

  Future<BackupHistoryEntity?> executeBackup({bool isAutoBackup = false}) async {
    state = const AsyncLoading();
    final usecase = ref.read(createBackupUsecaseProvider);
    final result = await usecase(isAutoBackup: isAutoBackup);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (history) {
        state = AsyncData(history);
        ref.invalidate(backupHistoryProvider);
        return history;
      },
    );
  }

  Future<bool> executeDelete(String id) async {
    state = const AsyncLoading();
    final usecase = ref.read(deleteBackupUsecaseProvider);
    final result = await usecase(id);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(backupHistoryProvider);
        return true;
      },
    );
  }

  Future<bool> executeShare(String filePath) async {
    state = const AsyncLoading();
    final usecase = ref.read(shareBackupUsecaseProvider);
    final result = await usecase(filePath);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

@riverpod
class RestoreNotifier extends _$RestoreNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> executeRestore(String filePath) async {
    state = const AsyncLoading();
    final usecase = ref.read(restoreBackupUsecaseProvider);
    final result = await usecase(filePath);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(backupHistoryProvider);
        return true;
      },
    );
  }

  Future<Map<String, dynamic>?> executeValidate(String filePath) async {
    state = const AsyncLoading();
    final usecase = ref.read(validateBackupFileUsecaseProvider);
    final result = await usecase(filePath);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (metadata) {
        state = const AsyncData(null);
        return metadata;
      },
    );
  }
}

// ── Settings Notifier ────────────────────────────────────────────────────────

class BackupSettingsState {
  final bool isAutoBackupEnabled;
  final String frequency;
  final int maxBackupCount;

  const BackupSettingsState({
    required this.isAutoBackupEnabled,
    required this.frequency,
    required this.maxBackupCount,
  });

  BackupSettingsState copyWith({
    bool? isAutoBackupEnabled,
    String? frequency,
    int? maxBackupCount,
  }) {
    return BackupSettingsState(
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      frequency: frequency ?? this.frequency,
      maxBackupCount: maxBackupCount ?? this.maxBackupCount,
    );
  }
}

@riverpod
class BackupSettingsNotifier extends _$BackupSettingsNotifier {
  static const _keyAutoBackup = 'auto_backup_enabled';
  static const _keyBackupFrequency = 'backup_frequency';
  static const _keyMaxBackupCount = 'max_backup_count';

  @override
  FutureOr<BackupSettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return BackupSettingsState(
      isAutoBackupEnabled: prefs.getBool(_keyAutoBackup) ?? false,
      frequency: prefs.getString(_keyBackupFrequency) ?? 'daily',
      maxBackupCount: prefs.getInt(_keyMaxBackupCount) ?? 5,
    );
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    state = const AsyncLoading();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackup, enabled);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isAutoBackupEnabled: enabled));
    }
  }

  Future<void> setFrequency(String frequency) async {
    state = const AsyncLoading();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBackupFrequency, frequency);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(frequency: frequency));
    }
  }

  Future<void> setMaxBackupCount(int count) async {
    state = const AsyncLoading();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxBackupCount, count);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(maxBackupCount: count));
    }
  }
  
  Future<void> cleanOldBackups() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(backupRepositoryProvider);
      final historyResult = await repo.getHistory();
      await historyResult.fold(
        (failure) async => throw failure,
        (historyList) async {
          final current = state.value;
          final maxCount = current?.maxBackupCount ?? 5;
          if (historyList.length > maxCount) {
            final toDeleteList = historyList.sublist(maxCount);
            for (final item in toDeleteList) {
              await repo.deleteBackup(item.id);
            }
          }
        },
      );
      final prefs = await SharedPreferences.getInstance();
      state = AsyncData(
        BackupSettingsState(
          isAutoBackupEnabled: prefs.getBool(_keyAutoBackup) ?? false,
          frequency: prefs.getString(_keyBackupFrequency) ?? 'daily',
          maxBackupCount: prefs.getInt(_keyMaxBackupCount) ?? 5,
        ),
      );
      ref.invalidate(backupHistoryProvider);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }
}
