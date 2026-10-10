// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_run_dao.dart';

// ignore_for_file: type=lint
mixin _$AiRunDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiRunsTable get aiRuns => attachedDatabase.aiRuns;
  AiRunDaoManager get managers => AiRunDaoManager(this);
}

class AiRunDaoManager {
  final _$AiRunDaoMixin _db;
  AiRunDaoManager(this._db);
  $$AiRunsTableTableManager get aiRuns =>
      $$AiRunsTableTableManager(_db.attachedDatabase, _db.aiRuns);
}
