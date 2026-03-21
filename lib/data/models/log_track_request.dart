import 'package:equatable/equatable.dart';

/// Request model for logging track playback to the server.
/// Matches the Android LogTrackRequestDto structure.
class LogTrackRequest extends Equatable {
  /// Duration played in seconds
  final int duration;
  
  /// Source of the track (e.g., "al:albumhash", "ar:artisthash", "fo:folderpath", "pl:playlistid", "favorite")
  final String source;
  
  /// Unix timestamp when the track was played
  final int timestamp;
  
  /// Unique hash identifier for the track
  final String trackhash;

  const LogTrackRequest({
    required this.duration,
    required this.source,
    required this.timestamp,
    required this.trackhash,
  });

  factory LogTrackRequest.fromJson(Map<String, dynamic> json) {
    return LogTrackRequest(
      duration: json['duration'] ?? 0,
      source: json['source'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      trackhash: json['trackhash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'source': source,
      'timestamp': timestamp,
      'trackhash': trackhash,
    };
  }

  @override
  List<Object?> get props => [duration, source, timestamp, trackhash];
}
