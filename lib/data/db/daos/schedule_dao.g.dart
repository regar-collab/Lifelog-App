// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduleDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiRunsTable get aiRuns => attachedDatabase.aiRuns;
  $SchedulesTable get schedules => attachedDatabase.schedules;
  ScheduleDaoManager get managers => ScheduleDaoManager(this);
}

class ScheduleDaoManager {
  final _$ScheduleDaoMixin _db;
  ScheduleDaoManager(this._db);
  $$AiRunsTableTableManager get aiRuns =>
      $$AiRunsTableTableManager(_db.attachedDatabase, _db.aiRuns);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
}
