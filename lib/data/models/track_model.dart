import 'package:equatable/equatable.dart';
import 'artist_model.dart';

class TrackModel extends Equatable {
  final int id;
  final String title;
  final String album;
  final String originalTitle;
  final String albumhash;
  final String originalAlbum;
  final List<ArtistModel> artists;
  final List<ArtistModel> albumartists;
  final List<String> artisthashes;
  final int track;
  final int disc;
  final int duration;
  final int bitrate;
  final String filepath;
  final String folder;
  final List<GenreModel> genres;
  final List<String> genrehashes;
  final String copyright;
  final int date;
  final int lastModified;
  final String trackhash;
  final String image;
  final String weakHash;
  final Map<String, dynamic> extra;
  final int lastplayed;
  final int playcount;
  final int playduration;
  final bool explicit;
  final List<int> favUserids;
  final bool isFavorite;
  final double score;

  const TrackModel({
    required this.id,
    required this.title,
    required this.album,
    this.originalTitle = '',
    required this.albumhash,
    this.originalAlbum = '',
    required this.artists,
    required this.albumartists,
    required this.artisthashes,
    required this.track,
    required this.disc,
    required this.duration,
    required this.bitrate,
    required this.filepath,
    required this.folder,
    required this.genres,
    required this.genrehashes,
    this.copyright = '',
    required this.date,
    required this.lastModified,
    required this.trackhash,
    this.image = '',
    this.weakHash = '',
    required this.extra,
    this.lastplayed = 0,
    this.playcount = 0,
    this.playduration = 0,
    this.explicit = false,
    this.favUserids = const [],
    this.isFavorite = false,
    this.score = 0.0,
  });

  TrackModel copyWith({
    int? id,
    String? title,
    String? album,
    String? originalTitle,
    String? albumhash,
    String? originalAlbum,
    List<ArtistModel>? artists,
    List<ArtistModel>? albumartists,
    List<String>? artisthashes,
    int? track,
    int? disc,
    int? duration,
    int? bitrate,
    String? filepath,
    String? folder,
    List<GenreModel>? genres,
    List<String>? genrehashes,
    String? copyright,
    int? date,
    int? lastModified,
    String? trackhash,
    String? image,
    String? weakHash,
    Map<String, dynamic>? extra,
    int? lastplayed,
    int? playcount,
    int? playduration,
    bool? explicit,
    List<int>? favUserids,
    bool? isFavorite,
    double? score,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      album: album ?? this.album,
      originalTitle: originalTitle ?? this.originalTitle,
      albumhash: albumhash ?? this.albumhash,
      originalAlbum: originalAlbum ?? this.originalAlbum,
      artists: artists ?? this.artists,
      albumartists: albumartists ?? this.albumartists,
      artisthashes: artisthashes ?? this.artisthashes,
      track: track ?? this.track,
      disc: disc ?? this.disc,
      duration: duration ?? this.duration,
      bitrate: bitrate ?? this.bitrate,
      filepath: filepath ?? this.filepath,
      folder: folder ?? this.folder,
      genres: genres ?? this.genres,
      genrehashes: genrehashes ?? this.genrehashes,
      copyright: copyright ?? this.copyright,
      date: date ?? this.date,
      lastModified: lastModified ?? this.lastModified,
      trackhash: trackhash ?? this.trackhash,
      image: image ?? this.image,
      weakHash: weakHash ?? this.weakHash,
      extra: extra ?? this.extra,
      lastplayed: lastplayed ?? this.lastplayed,
      playcount: playcount ?? this.playcount,
      playduration: playduration ?? this.playduration,
      explicit: explicit ?? this.explicit,
      favUserids: favUserids ?? this.favUserids,
      isFavorite: isFavorite ?? this.isFavorite,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        album,
        originalTitle,
        albumhash,
        originalAlbum,
        artists,
        albumartists,
        artisthashes,
        track,
        disc,
        duration,
        bitrate,
        filepath,
        folder,
        genres,
        genrehashes,
        copyright,
        date,
        lastModified,
        trackhash,
        image,
        weakHash,
        extra,
        lastplayed,
        playcount,
        playduration,
        explicit,
        favUserids,
        isFavorite,
        score,
      ];

  String get displayTitle => originalTitle.isNotEmpty ? originalTitle : title;

  String get displayAlbum => originalAlbum.isNotEmpty ? originalAlbum : album;

  String get artistNames => artists.map((artist) => artist.name).join(', ');

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      album: json['album'] ?? '',
      originalTitle: json['original_title'] ?? '',
      albumhash: json['albumhash'] ?? '',
      originalAlbum: json['original_album'] ?? '',
      artists: (json['artists'] as List<dynamic>?)
              ?.map((artist) => ArtistModel.fromJson(artist))
              .toList() ??
          [],
      albumartists: (json['albumartists'] as List<dynamic>?)
              ?.map((artist) => ArtistModel.fromJson(artist))
              .toList() ??
          [],
      artisthashes: List<String>.from(json['artisthashes'] ?? []),
      track: json['track'] ?? 0,
      disc: json['disc'] ?? 1,
      duration: json['duration'] ?? 0,
      bitrate: json['bitrate'] ?? 0,
      filepath: json['filepath'] ?? '',
      folder: json['folder'] ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => GenreModel.fromJson(genre))
              .toList() ??
          [],
      genrehashes: List<String>.from(json['genrehashes'] ?? []),
      copyright: json['copyright'] ?? '',
      date: json['date'] ?? 0,
      lastModified: json['last_modified'] ?? 0,
      trackhash: json['trackhash'] ?? '',
      image: json['image'] ?? '',
      weakHash: json['weak_hash'] ?? '',
      extra: json['extra'] ?? {},
      lastplayed: json['lastplayed'] ?? 0,
      playcount: json['playcount'] ?? 0,
      playduration: json['playduration'] ?? 0,
      explicit: json['explicit'] ?? false,
      favUserids: List<int>.from(json['fav_userids'] ?? []),
      isFavorite: json['is_favorite'] ?? false,
      score: (json['score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'original_title': originalTitle,
      'albumhash': albumhash,
      'original_album': originalAlbum,
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'albumartists': albumartists.map((artist) => artist.toJson()).toList(),
      'artisthashes': artisthashes,
      'track': track,
      'disc': disc,
      'duration': duration,
      'bitrate': bitrate,
      'filepath': filepath,
      'folder': folder,
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'genrehashes': genrehashes,
      'copyright': copyright,
      'date': date,
      'last_modified': lastModified,
      'trackhash': trackhash,
      'image': image,
      'weak_hash': weakHash,
      'extra': extra,
      'lastplayed': lastplayed,
      'playcount': playcount,
      'playduration': playduration,
      'explicit': explicit,
      'fav_userids': favUserids,
      'is_favorite': isFavorite,
      'score': score,
    };
  }
}

class GenreModel extends Equatable {
  final String name;
  final String genrehash;

  const GenreModel({
    required this.name,
    required this.genrehash,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      name: json['name'] ?? '',
      genrehash: json['genrehash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'genrehash': genrehash,
    };
  }

  @override
  List<Object?> get props => [name, genrehash];
}
