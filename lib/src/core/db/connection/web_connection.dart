import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

String dbFileName(String userId) =>
    'solo_leveling_${userId.replaceAll(RegExp('[^A-Za-z0-9_-]'), '')}';

QueryExecutor openConnection(String userId) => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: dbFileName(userId),
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
});
