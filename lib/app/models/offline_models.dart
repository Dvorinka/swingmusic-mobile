class OfflineTrack {
  const OfflineTrack({
    required this.trackhash,
    required this.title,
    required this.artist,
    required this.album,
    required this.remoteFilepath,
    required this.localPath,
    required this.downloadedAt,
    required this.quality,
  });

  final String trackhash;
  final String title;
  final String artist;
  final String album;
  final String remoteFilepath;
  final String localPath;
  final DateTime downloadedAt;
  final String quality;

  Map<String, dynamic> toMap() {
    return {
      'trackhash': trackhash,
      'title': title,
      'artist': artist,
      'album': album,
      'remoteFilepath': remoteFilepath,
      'localPath': localPath,
      'downloadedAt': downloadedAt.toIso8601String(),
      'quality': quality,
    };
  }

  factory OfflineTrack.fromMap(Map<dynamic, dynamic> map) {
    return OfflineTrack(
      trackhash: map['trackhash']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      artist: map['artist']?.toString() ?? '',
      album: map['album']?.toString() ?? '',
      remoteFilepath: map['remoteFilepath']?.toString() ?? '',
      localPath: map['localPath']?.toString() ?? '',
      downloadedAt:
          DateTime.tryParse(map['downloadedAt']?.toString() ?? '') ??
          DateTime.now(),
      quality: map['quality']?.toString() ?? '320',
    );
  }
}

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.trackhash,
    required this.title,
    required this.progress,
    required this.state,
    this.error,
  });

  final String id;
  final String trackhash;
  final String title;
  final double progress;
  final String state;
  final String? error;

  DownloadTask copyWith({double? progress, String? state, String? error}) {
    return DownloadTask(
      id: id,
      trackhash: trackhash,
      title: title,
      progress: progress ?? this.progress,
      state: state ?? this.state,
      error: error ?? this.error,
    );
  }
}

class PendingScrobble {
  const PendingScrobble({
    required this.id,
    required this.trackhash,
    required this.timestamp,
    required this.durationSeconds,
    required this.source,
  });

  final String id;
  final String trackhash;
  final int timestamp;
  final int durationSeconds;
  final String source;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackhash': trackhash,
      'timestamp': timestamp,
      'durationSeconds': durationSeconds,
      'source': source,
    };
  }

  factory PendingScrobble.fromMap(Map<dynamic, dynamic> map) {
    return PendingScrobble(
      id: map['id']?.toString() ?? '',
      trackhash: map['trackhash']?.toString() ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      source: map['source']?.toString() ?? '',
    );
  }
}

class PendingAction {
  const PendingAction({
    required this.id,
    required this.type,
    required this.payload,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'payload': payload};
  }

  factory PendingAction.fromMap(Map<dynamic, dynamic> map) {
    final rawPayload = map['payload'];
    return PendingAction(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      payload: rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : <String, dynamic>{},
    );
  }
}
