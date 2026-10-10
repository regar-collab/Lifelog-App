// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_dao.dart';

// ignore_for_file: type=lint
mixin _$TrackDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackSessionsTable get trackSessions => attachedDatabase.trackSessions;
  $TrackPointsTable get trackPoints => attachedDatabase.trackPoints;
  TrackDaoManager get managers => TrackDaoManager(this);
}

class TrackDaoManager {
  final _$TrackDaoMixin _db;
  TrackDaoManager(this._db);
  $$TrackSessionsTableTableManager get trackSessions =>
      $$TrackSessionsTableTableManager(_db.attachedDatabase, _db.trackSessions);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db.attachedDatabase, _db.trackPoints);
}
