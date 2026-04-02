import 'package:hive/hive.dart';

part 'sync_model.g.dart';

@HiveType(typeId: 0)
class SyncModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  SyncType type;

  @HiveField(2)
  Map<String, dynamic> data;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  int retryCount;

  @HiveField(5)
  int maxRetries;

  @HiveField(6)
  DateTime nextRetryTime;

  SyncModel({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.retryCount,
    required this.maxRetries,
    required this.nextRetryTime,
  });
}

@HiveType(typeId: 1)
enum SyncType {
  @HiveField(0)
  full,
  @HiveField(1)
  settings,
  @HiveField(2)
  library,
  @HiveField(3)
  playlists,
  @HiveField(4)
  history,
}
