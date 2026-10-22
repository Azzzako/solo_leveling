import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

const dbFileName = 'solo_leveling';

QueryExecutor openConnection() => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: dbFileName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
});
