import 'package:drift/drift.dart';

String dbFileName(String userId) => 'solo_leveling.sqlite';

QueryExecutor openConnection(String userId) =>
    throw UnsupportedError('Plataforma sin soporte de persistencia local');
