import 'package:equatable/equatable.dart';
import 'track_model.dart';

class FolderModel extends Equatable {
  final String name;
  final String path;
  final String? parent;
  final int trackcount;
  final List<FolderModel> subfolders;
  final List<TrackModel> tracks;
  final String? image;
  final bool isFavorite;

  const FolderModel({
    required this.name,
    required this.path,
    this.parent,
    this.trackcount = 0,
    this.subfolders = const [],
    this.tracks = const [],
    this.image,
    this.isFavorite = false,
  });

  FolderModel copyWith({
    String? name,
    String? path,
    String? parent,
    int? trackcount,
    List<FolderModel>? subfolders,
    List<TrackModel>? tracks,
    String? image,
    bool? isFavorite,
  }) {
    return FolderModel(
      name: name ?? this.name,
      path: path ?? this.path,
      parent: parent ?? this.parent,
      trackcount: trackcount ?? this.trackcount,
      subfolders: subfolders ?? this.subfolders,
      tracks: tracks ?? this.tracks,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      parent: json['parent'],
      trackcount: json['trackcount'] ?? 0,
      subfolders: (json['subfolders'] as List<dynamic>?)
          ?.map((folder) => FolderModel.fromJson(folder))
          .toList() ?? [],
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((track) => TrackModel.fromJson(track))
          .toList() ?? [],
      image: json['image'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'parent': parent,
      'trackcount': trackcount,
      'subfolders': subfolders.map((folder) => folder.toJson()).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'image': image,
      'is_favorite': isFavorite,
    };
  }

  @override
  List<Object?> get props => [
        name,
        path,
        parent,
        trackcount,
        subfolders,
        tracks,
        image,
        isFavorite,
      ];
}

class FoldersAndTracksModel extends Equatable {
  final List<FolderModel> folders;
  final List<TrackModel> tracks;
  final String currentPath;

  const FoldersAndTracksModel({
    required this.folders,
    required this.tracks,
    required this.currentPath,
  });

  factory FoldersAndTracksModel.fromJson(Map<String, dynamic> json) {
    return FoldersAndTracksModel(
      folders: (json['folders'] as List<dynamic>?)
          ?.map((folder) => FolderModel.fromJson(folder))
          .toList() ?? [],
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((track) => TrackModel.fromJson(track))
          .toList() ?? [],
      currentPath: json['current_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folders': folders.map((folder) => folder.toJson()).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'current_path': currentPath,
    };
  }

  @override
  List<Object?> get props => [folders, tracks, currentPath];
}
