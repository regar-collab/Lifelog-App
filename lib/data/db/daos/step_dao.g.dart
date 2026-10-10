// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_dao.dart';

// ignore_for_file: type=lint
mixin _$StepDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyStepsTable get dailySteps => attachedDatabase.dailySteps;
  StepDaoManager get managers => StepDaoManager(this);
}

class StepDaoManager {
  final _$StepDaoMixin _db;
  StepDaoManager(this._db);
  $$DailyStepsTableTableManager get dailySteps =>
      $$DailyStepsTableTableManager(_db.attachedDatabase, _db.dailySteps);
}
