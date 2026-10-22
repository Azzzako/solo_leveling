import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../missions/presentation/providers/interview_provider.dart';
import '../../../missions/presentation/providers/missions_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/backup_repository.dart';
import '../../domain/backup_format.dart';

abstract class BackupFiles {
  Future<bool> save(String fileName, Uint8List bytes);

  Future<Uint8List?> pick();
}

class SystemBackupFiles implements BackupFiles {
  const SystemBackupFiles();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: backupMimeType,
        dialogTitle: 'Guardar respaldo',
      ) !=
      null;

  @override
  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile(dialogTitle: 'Elegir respaldo');
    return file?.readAsBytes();
  }
}

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const SystemBackupFiles(),
);

final backupRepositoryProvider = FutureProvider<BackupRepository>((ref) async {
  final settings = await ref.watch(settingsStoreProvider.future);
  return BackupRepository(ref.watch(appDatabaseProvider), settings);
});

final lastBackupProvider = FutureProvider<DateTime?>((ref) async {
  final settings = await ref.watch(settingsStoreProvider.future);
  return settings.lastBackupAt;
});

final backupActionsProvider = Provider<BackupActions>(
  (ref) => BackupActions(ref),
);

class BackupActions {
  BackupActions(this._ref);

  final Ref _ref;

  Future<bool> export() async {
    final files = _ref.read(backupFilesProvider);
    final email = _ref.read(authProvider).value?.email ?? '';
    final settings = await _ref.read(settingsStoreProvider.future);
    final repository = await _ref.read(backupRepositoryProvider.future);
    final now = DateTime.now();
    final bytes = await repository.export(email: email, at: now);
    if (!await files.save(backupFileName(now), bytes)) return false;
    await settings.writeLastBackupAt(now);
    _ref.invalidate(lastBackupProvider);
    return true;
  }

  Future<BackupSnapshot?> pick() async {
    final files = _ref.read(backupFilesProvider);
    final repository = await _ref.read(backupRepositoryProvider.future);
    final bytes = await files.pick();
    if (bytes == null) return null;
    return repository.parse(bytes);
  }

  Future<void> restore(BackupSnapshot snapshot) async {
    final repository = await _ref.read(backupRepositoryProvider.future);
    await repository.restore(snapshot, today: _ref.read(todayProvider));
    _ref
      ..invalidate(playerProvider)
      ..invalidate(userPreferencesProvider)
      ..invalidate(dailySettlementProvider)
      ..invalidate(ensureDailyMissionsProvider);
  }
}
