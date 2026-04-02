import 'package:equatable/equatable.dart';
import 'album_model.dart';
import 'track_model.dart';

class ArtistModel extends Equatable {
  final String name;
  final String artisthash;
  final String image;
  final int trackcount;
  final int albumcount;
  final int duration;
  final int lastplayed;
  final int playcount;
  final int playduration;
  final List<int> favUserids;
  final bool isFavorite;
  final List<AlbumModel> albums;
  final List<TrackModel> tracks;

  const ArtistModel({
    required this.name,
    required this.artisthash,
    this.image = '',
    this.trackcount = 0,
    this.albumcount = 0,
    this.duration = 0,
    this.lastplayed = 0,
    this.playcount = 0,
    this.playduration = 0,
    this.favUserids = const [],
    this.isFavorite = false,
    this.albums = const [],
    this.tracks = const [],
  });

  ArtistModel copyWith({
    String? name,
    String? artisthash,
    String? image,
    int? trackcount,
    int? albumcount,
    int? duration,
    int? lastplayed,
    int? playcount,
    int? playduration,
    List<int>? favUserids,
    bool? isFavorite,
    List<AlbumModel>? albums,
    List<TrackModel>? tracks,
  }) {
    return ArtistModel(
      name: name ?? this.name,
      artisthash: artisthash ?? this.artisthash,
      image: image ?? this.image,
      trackcount: trackcount ?? this.trackcount,
      albumcount: albumcount ?? this.albumcount,
      duration: duration ?? this.duration,
      lastplayed: lastplayed ?? this.lastplayed,
      playcount: playcount ?? this.playcount,
      playduration: playduration ?? this.playduration,
      favUserids: favUserids ?? this.favUserids,
      isFavorite: isFavorite ?? this.isFavorite,
      albums: albums ?? this.albums,
      tracks: tracks ?? this.tracks,
    );
  }

  @override
  List<Object?> get props => [
        name,
        artisthash,
        image,
        trackcount,
        albumcount,
        duration,
        lastplayed,
        playcount,
        playduration,
        favUserids,
        isFavorite,
        albums,
        tracks,
      ];

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

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      name: json['name'] ?? '',
      artisthash: json['artisthash'] ?? '',
      image: json['image'] ?? '',
      trackcount: json['trackcount'] ?? 0,
      albumcount: json['albumcount'] ?? 0,
      duration: json['duration'] ?? 0,
      lastplayed: json['lastplayed'] ?? 0,
      playcount: json['playcount'] ?? 0,
      playduration: json['playduration'] ?? 0,
      favUserids: List<int>.from(json['fav_userids'] ?? []),
      isFavorite: json['is_favorite'] ?? false,
      albums: (json['albums'] as List<dynamic>?)
              ?.map((album) => AlbumModel.fromJson(album))
              .toList() ??
          [],
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((track) => TrackModel.fromJson(track))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artisthash': artisthash,
      'image': image,
      'trackcount': trackcount,
      'albumcount': albumcount,
      'duration': duration,
      'lastplayed': lastplayed,
      'playcount': playcount,
      'playduration': playduration,
      'fav_userids': favUserids,
      'is_favorite': isFavorite,
      'albums': albums.map((album) => album.toJson()).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }
}
