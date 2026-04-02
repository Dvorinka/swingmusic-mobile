import 'package:equatable/equatable.dart';
import 'track_model.dart';

class PlaylistModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<TrackModel> tracks;
  final int trackcount;
  final int duration;
  final DateTime createdDate;
  final DateTime lastModified;
  final bool isPublic;
  final bool isCollaborative;
  final String owner;
  final List<String> collaboratorIds;
  final Map<String, dynamic> extra;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.tracks = const [],
    this.trackcount = 0,
    this.duration = 0,
    required this.createdDate,
    required this.lastModified,
    this.isPublic = false,
    this.isCollaborative = false,
    this.owner = '',
    this.collaboratorIds = const [],
    this.extra = const {},
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    List<TrackModel>? tracks,
    int? trackcount,
    int? duration,
    DateTime? createdDate,
    DateTime? lastModified,
    bool? isPublic,
    bool? isCollaborative,
    String? owner,
    List<String>? collaboratorIds,
    Map<String, dynamic>? extra,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      tracks: tracks ?? this.tracks,
      trackcount: trackcount ?? this.trackcount,
      duration: duration ?? this.duration,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      owner: owner ?? this.owner,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      extra: extra ?? this.extra,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        tracks,
        trackcount,
        duration,
        createdDate,
        lastModified,
        isPublic,
        isCollaborative,
        owner,
        collaboratorIds,
        extra,
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

  String get createdDateFormatted {
    return '${createdDate.day.toString().padLeft(2, '0')}/${createdDate.month.toString().padLeft(2, '0')}/${createdDate.year}';
  }

  String get lastModifiedFormatted {
    return '${lastModified.day.toString().padLeft(2, '0')}/${lastModified.month.toString().padLeft(2, '0')}/${lastModified.year}';
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((track) => TrackModel.fromJson(track))
              .toList() ??
          [],
      trackcount: json['trackcount'] ?? 0,
      duration: json['duration'] ?? 0,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : DateTime.now(),
      lastModified: json['last_modified'] != null
          ? DateTime.parse(json['last_modified'])
          : DateTime.now(),
      isPublic: json['is_public'] ?? false,
      isCollaborative: json['is_collaborative'] ?? false,
      owner: json['owner'] ?? '',
      collaboratorIds: List<String>.from(json['collaborator_ids'] ?? []),
      extra: json['extra'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'trackcount': trackcount,
      'duration': duration,
      'created_date': createdDate.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
      'is_public': isPublic,
      'is_collaborative': isCollaborative,
      'owner': owner,
      'collaborator_ids': collaboratorIds,
      'extra': extra,
    };
  }
}
