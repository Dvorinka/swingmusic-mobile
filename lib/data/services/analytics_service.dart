import 'dart:async';
import '../models/track_model.dart';
import 'enhanced_api_service.dart';

class AnalyticsService {
  final EnhancedApiService _apiService;

  AnalyticsService(this._apiService);

  Future<Map<String, dynamic>> getAnalyticsData(String period) async {
    try {
      final analyticsData = await _apiService.getAnalyticsData(period);

      // Process and format the analytics data
      return {
        'totalPlays': analyticsData['total_plays'] ?? 0,
        'totalListeningTime':
            analyticsData['total_listening_time'] ?? 0, // minutes
        'uniqueTracksPlayed': analyticsData['unique_tracks_played'] ?? 0,
        'averageSessionLength': analyticsData['average_session_length'] ?? 0,
        'mostActiveDay': analyticsData['most_active_day'] ?? 'Monday',
        'peakHour': analyticsData['peak_hour'] ?? 12,
        'favoriteGenre': analyticsData['favorite_genre'] ?? 'Unknown',
        'topArtist': analyticsData['top_artist'] ?? 'Unknown',
        'topTracks': await _processTopTracks(analyticsData['top_tracks'] ?? []),
        'topArtists':
            await _processTopArtists(analyticsData['top_artists'] ?? []),
        'trendingUp':
            await _processTrendingTracks(analyticsData['trending_up'] ?? []),
        'trendingDown':
            await _processTrendingTracks(analyticsData['trending_down'] ?? []),
        'newDiscoveries': await _processTrendingTracks(
            analyticsData['new_discoveries'] ?? []),
      };
    } catch (e) {
      // Fallback to basic data if API fails
      return _getFallbackAnalyticsData();
    }
  }

  Future<List<TrackModel>> _processTopTracks(List<dynamic> tracksData) async {
    final tracks = <TrackModel>[];

    for (final trackData in tracksData) {
      try {
        final track = TrackModel.fromJson(trackData);
        tracks.add(track);
      } catch (e) {
        // Skip invalid track data
        continue;
      }
    }

    return tracks;
  }

  Future<List<Map<String, dynamic>>> _processTopArtists(
      List<dynamic> artistsData) async {
    final artists = <Map<String, dynamic>>[];

    for (final artistData in artistsData) {
      try {
        artists.add({
          'name': artistData['name'] ?? 'Unknown Artist',
          'artisthash': artistData['artisthash'] ?? '',
          'image': artistData['image'] ?? '',
          'trackcount': artistData['trackcount'] ?? 0,
          'albumcount': artistData['albumcount'] ?? 0,
          'duration': artistData['duration'] ?? 0,
          'lastplayed': artistData['lastplayed'] ?? 0,
          'playcount': artistData['playcount'] ?? 0,
          'playduration': artistData['playduration'] ?? 0,
          'favUserids': artistData['favUserids'] ?? [],
          'isFavorite': artistData['isFavorite'] ?? false,
          'albums': artistData['albums'] ?? [],
          'tracks': artistData['tracks'] ?? [],
        });
      } catch (e) {
        // Skip invalid artist data
        continue;
      }
    }

    return artists;
  }

  Future<List<TrackModel>> _processTrendingTracks(
      List<dynamic> tracksData) async {
    final tracks = <TrackModel>[];

    for (final trackData in tracksData) {
      try {
        final track = TrackModel.fromJson(trackData);
        tracks.add(track);
      } catch (e) {
        // Skip invalid track data
        continue;
      }
    }

    return tracks;
  }

  Map<String, dynamic> _getFallbackAnalyticsData() {
    return {
      'totalPlays': 0,
      'totalListeningTime': 0,
      'uniqueTracksPlayed': 0,
      'averageSessionLength': 0,
      'mostActiveDay': 'Monday',
      'peakHour': 12,
      'favoriteGenre': 'Unknown',
      'topArtist': 'Unknown',
      'topTracks': <TrackModel>[],
      'topArtists': <Map<String, dynamic>>[],
      'trendingUp': <TrackModel>[],
      'trendingDown': <TrackModel>[],
      'newDiscoveries': <TrackModel>[],
      'error': 'Failed to load analytics data',
    };
  }

  Future<List<TrackModel>> getTopTracks({int limit = 10}) async {
    try {
      final tracksData = await _apiService.getTopTracks(limit: limit);

      final tracks = <TrackModel>[];
      for (final trackData in tracksData) {
        try {
          final track = TrackModel.fromJson(trackData);
          tracks.add(track);
        } catch (e) {
          continue;
        }
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopArtists({int limit = 10}) async {
    try {
      final artistsData = await _apiService.getTopArtists(limit: limit);

      return _processTopArtists(artistsData);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getListeningStats() async {
    try {
      final analyticsData = await _apiService.getAnalyticsData('all_time');

      return {
        'totalTracks': analyticsData['total_tracks'] ?? 0,
        'totalArtists': analyticsData['total_artists'] ?? 0,
        'totalAlbums': analyticsData['total_albums'] ?? 0,
        'totalGenres': analyticsData['total_genres'] ?? 0,
        'totalPlayTime': analyticsData['total_play_time'] ?? 0,
        'averageDailyPlayTime': analyticsData['average_daily_play_time'] ?? 0,
        'mostPlayedDay': analyticsData['most_played_day'] ?? 'Monday',
        'listeningStreak': analyticsData['listening_streak'] ?? 0,
      };
    } catch (e) {
      return _getFallbackListeningStats();
    }
  }

  Map<String, dynamic> _getFallbackListeningStats() {
    return {
      'totalTracks': 0,
      'totalArtists': 0,
      'totalAlbums': 0,
      'totalGenres': 0,
      'totalPlayTime': 0,
      'averageDailyPlayTime': 0,
      'mostPlayedDay': 'Monday',
      'listeningStreak': 0,
      'error': 'Failed to load listening stats',
    };
  }

  Future<Map<String, dynamic>> getGenreDistribution() async {
    try {
      final analyticsData = await _apiService.getAnalyticsData('all_time');
      final genreData = analyticsData['genre_distribution'] ?? {};

      // Process genre distribution
      final processedGenres = <String, dynamic>{};
      for (final genre in genreData.keys) {
        processedGenres[genre] = {
          'count': genreData[genre]['count'] ?? 0,
          'percentage': genreData[genre]['percentage'] ?? 0.0,
          'totalPlayTime': genreData[genre]['total_play_time'] ?? 0,
        };
      }

      return processedGenres;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getListeningHistory({int days = 30}) async {
    try {
      final analyticsData = await _apiService.getAnalyticsData('$days days');
      final historyData = analyticsData['listening_history'] ?? [];

      // Process listening history
      final processedHistory = <Map<String, dynamic>>[];
      for (final dayData in historyData) {
        processedHistory.add({
          'date': dayData['date'] ?? '',
          'tracksPlayed': dayData['tracks_played'] ?? 0,
          'playTime': dayData['play_time'] ?? 0,
          'topTrack': dayData['top_track'] ?? {},
          'topArtist': dayData['top_artist'] ?? {},
        });
      }

      return {
        'history': processedHistory,
        'totalDays': processedHistory.length,
      };
    } catch (e) {
      return {
        'history': <Map<String, dynamic>>[],
        'totalDays': 0,
        'error': 'Failed to load listening history',
      };
    }
  }
}
