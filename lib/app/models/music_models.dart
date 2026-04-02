class MusicTrack {
  const MusicTrack({
    required this.trackhash,
    required this.title,
    required this.artist,
    required this.album,
    required this.filepath,
    required this.durationSeconds,
    required this.bitrate,
    this.imageUrl,
    this.albumhash,
    this.spotifyId,
    this.isFavorite = false,
    this.importAvailable = false,
    this.availability = const {},
  });

  final String trackhash;
  final String title;
  final String artist;
  final String album;
  final String filepath;
  final int durationSeconds;
  final int bitrate;
  final String? imageUrl;
  final String? albumhash;
  final String? spotifyId;
  final bool isFavorite;
  final bool importAvailable;
  final Map<String, dynamic> availability;

  String get id => trackhash.isNotEmpty ? trackhash : (spotifyId ?? title);

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get qualityLabel {
    if (bitrate <= 0) return '-';
    return '${bitrate}kbps';
  }

  String get availabilityState =>
      availability['state']?.toString() ?? 'unknown';

  MusicTrack copyWith({
    bool? isFavorite,
    bool? importAvailable,
    Map<String, dynamic>? availability,
  }) {
    return MusicTrack(
      trackhash: trackhash,
      title: title,
      artist: artist,
      album: album,
      filepath: filepath,
      durationSeconds: durationSeconds,
      bitrate: bitrate,
      imageUrl: imageUrl,
      albumhash: albumhash,
      spotifyId: spotifyId,
      isFavorite: isFavorite ?? this.isFavorite,
      importAvailable: importAvailable ?? this.importAvailable,
      availability: availability ?? this.availability,
    );
  }

  factory MusicTrack.fromLibraryJson(Map<String, dynamic> json) {
    final artists = json['artists'];
    final artist =
        _firstArtistName(artists) ?? json['artist']?.toString() ?? '';

    return MusicTrack(
      trackhash: json['trackhash']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: artist,
      album: json['album']?.toString() ?? '',
      filepath: json['filepath']?.toString() ?? '',
      durationSeconds: _asInt(json['duration']),
      bitrate: _asInt(json['bitrate']),
      imageUrl: json['image']?.toString(),
      albumhash: json['albumhash']?.toString(),
      isFavorite: json['is_favorite'] == true,
      importAvailable: json['import_available'] == true,
      availability: _asMap(json['availability']),
    );
  }

  factory MusicTrack.fromCatalogJson(Map<String, dynamic> json) {
    final fallbackArtist = json['artist']?.toString() ?? '';
    final artist = _firstArtistName(json['artists']) ?? fallbackArtist;
    final durationMs = _asInt(json['duration_ms']);

    return MusicTrack(
      trackhash: json['trackhash']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      artist: artist,
      album: json['album']?.toString() ?? '',
      filepath: json['filepath']?.toString() ?? '',
      durationSeconds:
          durationMs > 0 ? (durationMs ~/ 1000) : _asInt(json['duration']),
      bitrate: _asInt(json['bitrate']),
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      albumhash: json['albumhash']?.toString(),
      spotifyId: json['spotify_id']?.toString(),
      isFavorite: json['is_favorite'] == true,
      importAvailable: json['import_available'] == true,
      availability: _asMap(json['availability']),
    );
  }
}

class MusicAlbum {
  const MusicAlbum({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.albumhash,
    this.spotifyId,
    this.trackCount = 0,
    this.availability = const {},
  });

  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String? albumhash;
  final String? spotifyId;
  final int trackCount;
  final Map<String, dynamic> availability;

  String get availabilityState =>
      availability['state']?.toString() ?? 'unknown';

  factory MusicAlbum.fromLibraryJson(Map<String, dynamic> json) {
    final albumArtists = json['albumartists'];
    final artist =
        _firstArtistName(albumArtists) ?? json['artist']?.toString() ?? '';
    final hash = json['albumhash']?.toString() ?? '';

    return MusicAlbum(
      id: hash.isNotEmpty
          ? hash
          : json['id']?.toString() ?? json['title']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: artist,
      imageUrl: json['image']?.toString(),
      albumhash: hash,
      trackCount: _asInt(json['trackcount']),
      availability: _asMap(json['availability']),
    );
  }

  factory MusicAlbum.fromCatalogJson(Map<String, dynamic> json) {
    final spotifyId = json['spotify_id']?.toString();
    return MusicAlbum(
      id: spotifyId ??
          json['albumhash']?.toString() ??
          json['title']?.toString() ??
          '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      albumhash: json['albumhash']?.toString(),
      spotifyId: spotifyId,
      trackCount: _asInt(json['trackcount']),
      availability: _asMap(json['availability']),
    );
  }
}

class MusicArtist {
  const MusicArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.artisthash,
    this.spotifyId,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final String? artisthash;
  final String? spotifyId;

  factory MusicArtist.fromLibraryJson(Map<String, dynamic> json) {
    final hash = json['artisthash']?.toString() ?? '';
    return MusicArtist(
      id: hash.isNotEmpty ? hash : json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['image']?.toString(),
      artisthash: hash,
    );
  }

  factory MusicArtist.fromCatalogJson(Map<String, dynamic> json) {
    final spotifyId = json['spotify_id']?.toString();
    return MusicArtist(
      id: spotifyId ?? json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      spotifyId: spotifyId,
    );
  }
}

class MusicPlaylist {
  const MusicPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.trackCount = 0,
    this.spotifyId,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int trackCount;
  final String? spotifyId;

  factory MusicPlaylist.fromLibraryJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return MusicPlaylist(
      id: id,
      name: json['name']?.toString() ?? '',
      imageUrl: json['image']?.toString(),
      trackCount: _asInt(json['count']),
    );
  }

  factory MusicPlaylist.fromCatalogJson(Map<String, dynamic> json) {
    final spotifyId = json['spotify_id']?.toString();
    return MusicPlaylist(
      id: spotifyId ?? json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      trackCount: _asInt(json['tracks_total']),
      spotifyId: spotifyId,
    );
  }
}

class FolderEntry {
  const FolderEntry({
    required this.name,
    required this.path,
    required this.trackCount,
  });

  final String name;
  final String path;
  final int trackCount;

  factory FolderEntry.fromJson(Map<String, dynamic> json) {
    return FolderEntry(
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      trackCount: _asInt(json['trackcount']),
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String? _firstArtistName(dynamic artists) {
  if (artists is List && artists.isNotEmpty) {
    final first = artists.first;
    if (first is Map) {
      return first['name']?.toString();
    }
  }
  return null;
}
