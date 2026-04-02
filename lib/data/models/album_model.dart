import 'package:equatable/equatable.dart';
import 'track_model.dart';
import 'artist_model.dart';

class AlbumModel extends Equatable {
  final List<ArtistModel> albumartists;
  final String albumhash;
  final List<String> artisthashes;
  final String baseTitle;
  final String color;
  final int createdDate;
  final int date;
  final int duration;
  final List<GenreModel> genres;
  final List<String> genrehashes;
  final String originalTitle;
  final String title;
  final int trackcount;
  final int lastplayed;
  final int playcount;
  final int playduration;
  final Map<String, dynamic> extra;
  final String pathhash;
  final int id;
  final String type;
  final String image;
  final double score;
  final List<String> versions;
  final List<int> favUserids;
  final String weakHash;
  final bool isFavorite;

  const AlbumModel({
    required this.albumartists,
    required this.albumhash,
    required this.artisthashes,
    required this.baseTitle,
    this.color = '#6750A4',
    required this.createdDate,
    required this.date,
    required this.duration,
    required this.genres,
    required this.genrehashes,
    this.originalTitle = '',
    required this.title,
    required this.trackcount,
    this.lastplayed = 0,
    this.playcount = 0,
    this.playduration = 0,
    this.extra = const {},
    this.pathhash = '',
    this.id = -1,
    this.type = 'album',
    this.image = '',
    this.score = 0.0,
    this.versions = const [],
    this.favUserids = const [],
    this.weakHash = '',
    this.isFavorite = false,
  });

  AlbumModel copyWith({
    List<ArtistModel>? albumartists,
    String? albumhash,
    List<String>? artisthashes,
    String? baseTitle,
    String? color,
    int? createdDate,
    int? date,
    int? duration,
    List<GenreModel>? genres,
    List<String>? genrehashes,
    String? originalTitle,
    String? title,
    int? trackcount,
    int? lastplayed,
    int? playcount,
    int? playduration,
    Map<String, dynamic>? extra,
    String? pathhash,
    int? id,
    String? type,
    String? image,
    double? score,
    List<String>? versions,
    List<int>? favUserids,
    String? weakHash,
    bool? isFavorite,
  }) {
    return AlbumModel(
      albumartists: albumartists ?? this.albumartists,
      albumhash: albumhash ?? this.albumhash,
      artisthashes: artisthashes ?? this.artisthashes,
      baseTitle: baseTitle ?? this.baseTitle,
      color: color ?? this.color,
      createdDate: createdDate ?? this.createdDate,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      genres: genres ?? this.genres,
      genrehashes: genrehashes ?? this.genrehashes,
      originalTitle: originalTitle ?? this.originalTitle,
      title: title ?? this.title,
      trackcount: trackcount ?? this.trackcount,
      lastplayed: lastplayed ?? this.lastplayed,
      playcount: playcount ?? this.playcount,
      playduration: playduration ?? this.playduration,
      extra: extra ?? this.extra,
      pathhash: pathhash ?? this.pathhash,
      id: id ?? this.id,
      type: type ?? this.type,
      image: image ?? this.image,
      score: score ?? this.score,
      versions: versions ?? this.versions,
      favUserids: favUserids ?? this.favUserids,
      weakHash: weakHash ?? this.weakHash,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        albumartists,
        albumhash,
        artisthashes,
        baseTitle,
        color,
        createdDate,
        date,
        duration,
        genres,
        genrehashes,
        originalTitle,
        title,
        trackcount,
        lastplayed,
        playcount,
        playduration,
        extra,
        pathhash,
        id,
        type,
        image,
        score,
        versions,
        favUserids,
        weakHash,
        isFavorite,
      ];

  String get displayTitle => originalTitle.isNotEmpty ? originalTitle : title;

  String get artistNames =>
      albumartists.map((artist) => artist.name).join(', ');
  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get year {
    if (date == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    return dateTime.year.toString();
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      albumartists: (json['albumartists'] as List<dynamic>?)
              ?.map((artist) => ArtistModel.fromJson(artist))
              .toList() ??
          [],
      albumhash: json['albumhash'] ?? '',
      artisthashes: List<String>.from(json['artisthashes'] ?? []),
      baseTitle: json['base_title'] ?? '',
      color: json['color'] ?? '#6750A4',
      createdDate: json['created_date'] ?? 0,
      date: json['date'] ?? 0,
      duration: json['duration'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => GenreModel.fromJson(genre))
              .toList() ??
          [],
      genrehashes: List<String>.from(json['genrehashes'] ?? []),
      originalTitle: json['original_title'] ?? '',
      title: json['title'] ?? '',
      trackcount: json['trackcount'] ?? 0,
      lastplayed: json['lastplayed'] ?? 0,
      playcount: json['playcount'] ?? 0,
      playduration: json['playduration'] ?? 0,
      extra: json['extra'] ?? {},
      pathhash: json['pathhash'] ?? '',
      id: json['id'] ?? -1,
      type: json['type'] ?? 'album',
      image: json['image'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      versions: List<String>.from(json['versions'] ?? []),
      favUserids: List<int>.from(json['fav_userids'] ?? []),
      weakHash: json['weak_hash'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumartists': albumartists.map((artist) => artist.toJson()).toList(),
      'albumhash': albumhash,
      'artisthashes': artisthashes,
      'base_title': baseTitle,
      'color': color,
      'created_date': createdDate,
      'date': date,
      'duration': duration,
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'genrehashes': genrehashes,
      'original_title': originalTitle,
      'title': title,
      'trackcount': trackcount,
      'lastplayed': lastplayed,
      'playcount': playcount,
      'playduration': playduration,
      'extra': extra,
      'pathhash': pathhash,
      'id': id,
      'type': type,
      'image': image,
      'score': score,
      'versions': versions,
      'fav_userids': favUserids,
      'weak_hash': weakHash,
      'is_favorite': isFavorite,
    };
  }
}
