import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const dbFileName = 'solo_leveling.sqlite';

QueryExecutor openConnection() => LazyDatabase(() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, dbFileName));
  return NativeDatabase.createInBackground(file);
});
