import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const legacyDbFileName = 'solo_leveling.sqlite';

String dbFileName(String userId) => 'solo_leveling_${_sanitize(userId)}.sqlite';

String _sanitize(String userId) =>
    userId.replaceAll(RegExp('[^A-Za-z0-9_-]'), '');

QueryExecutor openConnection(String userId) => LazyDatabase(() async {
  final dir = await getApplicationSupportDirectory();
  await adoptLegacyDatabase(userId, dir);
  return NativeDatabase.createInBackground(
    File(p.join(dir.path, dbFileName(userId))),
  );
});

Future<void> adoptLegacyDatabase(String userId, Directory dir) async {
  final legacy = File(p.join(dir.path, legacyDbFileName));
  final target = File(p.join(dir.path, dbFileName(userId)));
  if (!legacy.existsSync() || target.existsSync()) return;
  await legacy.copy(target.path);
}
