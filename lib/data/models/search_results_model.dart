import 'package:equatable/equatable.dart';
import 'album_model.dart';
import 'folder_model.dart';
import 'playlist_model.dart';
import 'track_model.dart';

class SearchResultsModel extends Equatable {
  final List<TrackModel> tracks;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<FolderModel> folders;
  final List<PlaylistModel> playlists;

  const SearchResultsModel({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.folders = const [],
    this.playlists = const [],
  });

  SearchResultsModel copyWith({
    List<TrackModel>? tracks,
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    List<FolderModel>? folders,
    List<PlaylistModel>? playlists,
  }) {
    return SearchResultsModel(
      tracks: tracks ?? this.tracks,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      folders: folders ?? this.folders,
      playlists: playlists ?? this.playlists,
    );
  }

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) {
    return SearchResultsModel(
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((track) => TrackModel.fromJson(track))
          .toList() ?? [],
      albums: (json['albums'] as List<dynamic>?)
          ?.map((album) => AlbumModel.fromJson(album))
          .toList() ?? [],
      artists: (json['artists'] as List<dynamic>?)
          ?.map((artist) => ArtistModel.fromJson(artist))
          .toList() ?? [],
      folders: (json['folders'] as List<dynamic>?)
          ?.map((folder) => FolderModel.fromJson(folder))
          .toList() ?? [],
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((playlist) => PlaylistModel.fromJson(playlist))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'albums': albums.map((album) => album.toJson()).toList(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'folders': folders.map((folder) => folder.toJson()).toList(),
      'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
    };
  }

  bool get isEmpty => 
      tracks.isEmpty && 
      albums.isEmpty && 
      artists.isEmpty && 
      folders.isEmpty && 
      playlists.isEmpty;

  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        tracks,
        albums,
        artists,
        folders,
        playlists,
      ];
}

class TopSearchResultsModel extends Equatable {
  final List<TopResultItemModel> topResults;
  final SearchResultsModel allResults;

  const TopSearchResultsModel({
    required this.topResults,
    required this.allResults,
  });

  factory TopSearchResultsModel.fromJson(Map<String, dynamic> json) {
    return TopSearchResultsModel(
      topResults: (json['top_results'] as List<dynamic>?)
          ?.map((item) => TopResultItemModel.fromJson(item))
          .toList() ?? [],
      allResults: SearchResultsModel.fromJson(json['all_results'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_results': topResults.map((item) => item.toJson()).toList(),
      'all_results': allResults.toJson(),
    };
  }

  @override
  List<Object?> get props => [topResults, allResults];
}

class TopResultItemModel extends Equatable {
  final String type; // 'track', 'album', 'artist', 'folder', 'playlist'
  final String title;
  final String subtitle;
  final String? image;
  final dynamic data; // The actual model object

  const TopResultItemModel({
    required this.type,
    required this.title,
    required this.subtitle,
    this.image,
    this.data,
  });

  factory TopResultItemModel.fromJson(Map<String, dynamic> json) {
    return TopResultItemModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'data': data,
    };
  }

  @override
  List<Object?> get props => [type, title, subtitle, image, data];
}
