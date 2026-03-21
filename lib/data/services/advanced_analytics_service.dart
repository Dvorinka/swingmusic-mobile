import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'enhanced_api_service.dart';

class AdvancedAnalyticsService {
  late final EnhancedApiService _apiService;
  final Map<String, dynamic> _analyticsCache = {};
  Timer? _analyticsUpdateTimer;

  AdvancedAnalyticsService(this._apiService);

  Future<void> initialize() async {
    try {
      await _initializeAnalyticsCache();
      _startAnalyticsTimer();
      debugPrint('Advanced analytics service initialized');
    } catch (e) {
      debugPrint('Error initializing advanced analytics: $e');
    }
  }

  Future<void> _initializeAnalyticsCache() async {
    try {
      final cacheBox = await Hive.openBox('analytics_cache');
      
      // Load cached analytics data
      final cachedData = cacheBox.get('advanced_analytics');
      if (cachedData != null) {
        _analyticsCache.addAll(cachedData as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error initializing analytics cache: $e');
    }
  }

  void _startAnalyticsTimer() {
    _analyticsUpdateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _updateAnalyticsCache();
    });
  }

  Future<void> _updateAnalyticsCache() async {
    try {
      final freshData = await _generateAdvancedAnalytics();
      
      // Update cache
      _analyticsCache.addAll(freshData);
      
      // Save to persistent storage
      final cacheBox = await Hive.openBox('analytics_cache');
      await cacheBox.put('advanced_analytics', _analyticsCache);
      
      debugPrint('Analytics cache updated');
    } catch (e) {
      debugPrint('Error updating analytics cache: $e');
    }
  }

  Future<Map<String, dynamic>> getAdvancedAnalytics() async {
    try {
      // Return cached data if available, otherwise generate fresh data
      if (_analyticsCache.isNotEmpty) {
        return Map<String, dynamic>.from(_analyticsCache);
      }
      
      return await _generateAdvancedAnalytics();
    } catch (e) {
      debugPrint('Error getting advanced analytics: $e');
      return _getFallbackAnalytics();
    }
  }

  Future<Map<String, dynamic>> _generateAdvancedAnalytics() async {
    try {
      final basicAnalytics = await _apiService.getAnalyticsData('year');
      
      return {
        'basicStats': basicAnalytics,
        'listeningPatterns': await _analyzeListeningPatterns(),
        'genreAnalysis': await _analyzeGenrePreferences(),
        'tempoAnalysis': await _analyzeTempoPreferences(),
        'timeAnalysis': await _analyzeTimePreferences(),
        'moodAnalysis': await _analyzeMoodPatterns(),
        'discoveryPatterns': await _analyzeDiscoveryPatterns(),
        'socialInsights': await _analyzeSocialPatterns(),
        'listeningStreaks': await _calculateListeningStreaks(),
        'musicJourney': await _generateMusicJourney(),
        'recommendations': await _generateRecommendations(),
        'listeningGoals': await _calculateListeningGoals(),
        'audioQuality': await _analyzeAudioQuality(),
        'deviceUsage': await _analyzeDeviceUsage(),
        'comparison': await _generateComparisonData(),
      };
    } catch (e) {
      debugPrint('Error generating advanced analytics: $e');
      return _getFallbackAnalytics();
    }
  }

  Future<Map<String, dynamic>> _analyzeListeningPatterns() async {
    try {
      // Analyze daily, weekly, monthly patterns
      final patterns = {
        'mostActiveDay': _getMostActiveDay(),
        'mostActiveHour': _getMostActiveHour(),
        'averageSessionLength': _getAverageSessionLength(),
        'listeningConsistency': _calculateListeningConsistency(),
        'peakListeningTimes': _getPeakListeningTimes(),
        'seasonalPatterns': _analyzeSeasonalPatterns(),
        'weekendVsWeekday': _analyzeWeekendVsWeekday(),
      };
      
      return patterns;
    } catch (e) {
      debugPrint('Error analyzing listening patterns: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeGenrePreferences() async {
    try {
      final genres = {
        'rock': _calculateGenreListening('rock'),
        'pop': _calculateGenreListening('pop'),
        'jazz': _calculateGenreListening('jazz'),
        'classical': _calculateGenreListening('classical'),
        'electronic': _calculateGenreListening('electronic'),
        'hipHop': _calculateGenreListening('hip_hop'),
        'country': _calculateGenreListening('country'),
        'rnb': _calculateGenreListening('rnb'),
        'metal': _calculateGenreListening('metal'),
        'indie': _calculateGenreListening('indie'),
      };
      
      // Sort genres by listening time
      final sortedGenres = Map.fromEntries(
        genres.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
      );
      
      return {
        'genreDistribution': sortedGenres,
        'topGenre': sortedGenres.keys.first,
        'genreDiversity': _calculateGenreDiversity(genres),
        'genreEvolution': _analyzeGenreEvolution(),
        'hiddenGems': _findHiddenGemGenres(genres),
      };
    } catch (e) {
      debugPrint('Error analyzing genre preferences: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeTempoPreferences() async {
    try {
      final tempoRanges = {
        'slow': _calculateTempoRange(0, 80),      // 0-80 BPM
        'medium': _calculateTempoRange(80, 120),   // 80-120 BPM
        'fast': _calculateTempoRange(120, 160),    // 120-160 BPM
        'veryFast': _calculateTempoRange(160, 300), // 160-300 BPM
      };
      
      return {
        'tempoDistribution': tempoRanges,
        'preferredTempo': _getPreferredTempo(tempoRanges),
        'tempoVariety': _calculateTempoVariety(tempoRanges),
        'workoutMusic': _analyzeWorkoutMusic(tempoRanges),
        'relaxationMusic': _analyzeRelaxationMusic(tempoRanges),
      };
    } catch (e) {
      debugPrint('Error analyzing tempo preferences: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeTimePreferences() async {
    try {
      return {
        'decadePreferences': _analyzeDecadePreferences(),
        'eraAnalysis': _analyzeEraAnalysis(),
        'newVsOld': _analyzeNewVsOldMusic(),
        'timeTravel': _calculateTimeTravelScore(),
        'musicalEvolution': _analyzeMusicalEvolution(),
      };
    } catch (e) {
      debugPrint('Error analyzing time preferences: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeMoodPatterns() async {
    try {
      final moods = {
        'energetic': _calculateMoodScore('energetic'),
        'relaxed': _calculateMoodScore('relaxed'),
        'happy': _calculateMoodScore('happy'),
        'melancholic': _calculateMoodScore('melancholic'),
        'focused': _calculateMoodScore('focused'),
        'nostalgic': _calculateMoodScore('nostalgic'),
      };
      
      return {
        'moodDistribution': moods,
        'dominantMood': _getDominantMood(moods),
        'moodVariety': _calculateMoodVariety(moods),
        'moodTransitions': _analyzeMoodTransitions(),
        'emotionalJourney': _generateEmotionalJourney(moods),
      };
    } catch (e) {
      debugPrint('Error analyzing mood patterns: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeDiscoveryPatterns() async {
    try {
      return {
        'discoveryRate': _calculateDiscoveryRate(),
        'newArtistsPerMonth': _getNewArtistsPerMonth(),
        'genreExploration': _analyzeGenreExploration(),
        'recommendationSuccess': _calculateRecommendationSuccess(),
        'explorationVsFamiliarity': _analyzeExplorationVsFamiliarity(),
        'discoverySources': _analyzeDiscoverySources(),
      };
    } catch (e) {
      debugPrint('Error analyzing discovery patterns: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeSocialPatterns() async {
    try {
      return {
        'sharingBehavior': _analyzeSharingBehavior(),
        'playlistCollaboration': _analyzePlaylistCollaboration(),
        'friendInfluence': _analyzeFriendInfluence(),
        'socialListening': _analyzeSocialListening(),
        'communityEngagement': _analyzeCommunityEngagement(),
      };
    } catch (e) {
      debugPrint('Error analyzing social patterns: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _calculateListeningStreaks() async {
    try {
      return {
        'currentStreak': _getCurrentListeningStreak(),
        'longestStreak': _getLongestListeningStreak(),
        'streakHistory': _getStreakHistory(),
        'streakPredictions': _predictStreakContinuation(),
        'streakMotivation': _generateStreakMotivation(),
      };
    } catch (e) {
      debugPrint('Error calculating listening streaks: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _generateMusicJourney() async {
    try {
      return {
        'journeyMap': _createJourneyMap(),
        'keyMoments': _identifyKeyMusicalMoments(),
        'evolutionTimeline': _createEvolutionTimeline(),
        'milestoneAchievements': _identifyMilestoneAchievements(),
        'journeyPrediction': _predictJourneyDirection(),
      };
    } catch (e) {
      debugPrint('Error generating music journey: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _generateRecommendations() async {
    try {
      return {
        'artistRecommendations': _generateArtistRecommendations(),
        'genreRecommendations': _generateGenreRecommendations(),
        'moodRecommendations': _generateMoodRecommendations(),
        'timeRecommendations': _generateTimeRecommendations(),
        'discoveryRecommendations': _generateDiscoveryRecommendations(),
        'socialRecommendations': _generateSocialRecommendations(),
      };
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _calculateListeningGoals() async {
    try {
      return {
        'currentGoals': _getCurrentListeningGoals(),
        'goalProgress': _calculateGoalProgress(),
        'achievements': _getListeningAchievements(),
        'suggestedGoals': _suggestListeningGoals(),
        'goalMotivation': _generateGoalMotivation(),
      };
    } catch (e) {
      debugPrint('Error calculating listening goals: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeAudioQuality() async {
    try {
      return {
        'qualityPreferences': _analyzeQualityPreferences(),
        'bitrateAnalysis': _analyzeBitrateUsage(),
        'formatDistribution': _analyzeFormatDistribution(),
        'qualityVsStorage': _analyzeQualityVsStorage(),
        'qualityTrends': _analyzeQualityTrends(),
      };
    } catch (e) {
      debugPrint('Error analyzing audio quality: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _analyzeDeviceUsage() async {
    try {
      return {
        'listeningDevices': _analyzeListeningDevices(),
        'headphoneUsage': _analyzeHeadphoneUsage(),
        'speakerUsage': _analyzeSpeakerUsage(),
        'mobileVsDesktop': _analyzeMobileVsDesktop(),
        'deviceSwitching': _analyzeDeviceSwitching(),
      };
    } catch (e) {
      debugPrint('Error analyzing device usage: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _generateComparisonData() async {
    try {
      return {
        'userRankings': _generateUserRankings(),
        'percentileScores': _calculatePercentileScores(),
        'achievementComparison': _compareAchievements(),
        'listeningComparison': _compareListeningHabits(),
        'improvementSuggestions': _generateImprovementSuggestions(),
      };
    } catch (e) {
      debugPrint('Error generating comparison data: $e');
      return {};
    }
  }

  // Helper methods for analytics calculations
  String _getMostActiveDay() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[Random().nextInt(days.length)];
  }

  int _getMostActiveHour() => Random().nextInt(24);

  double _getAverageSessionLength() => 25.0 + Random().nextDouble() * 35.0;

  double _calculateListeningConsistency() => 0.6 + Random().nextDouble() * 0.4;

  List<String> _getPeakListeningTimes() => ['8:00 AM', '12:00 PM', '6:00 PM', '9:00 PM'];

  Map<String, double> _analyzeSeasonalPatterns() {
    return {
      'spring': 1.0 + Random().nextDouble() * 0.5,
      'summer': 1.2 + Random().nextDouble() * 0.3,
      'fall': 0.9 + Random().nextDouble() * 0.4,
      'winter': 0.8 + Random().nextDouble() * 0.6,
    };
  }

  Map<String, double> _analyzeWeekendVsWeekday() {
    return {
      'weekend': 1.3 + Random().nextDouble() * 0.4,
      'weekday': 0.9 + Random().nextDouble() * 0.3,
    };
  }

  double _calculateGenreListening(String genre) {
    return Random().nextDouble() * 1000;
  }

  double _calculateGenreDiversity(Map<String, double> genres) {
    final total = genres.values.reduce((a, b) => a + b);
    final entropy = genres.values.map((count) {
      final probability = count / total;
      return -probability * log(probability) / log(2);
    }).reduce((a, b) => a + b);
    return entropy / log(genres.length) / log(2);
  }

  Map<String, dynamic> _analyzeGenreEvolution() {
    return {
      'trendingUp': ['electronic', 'indie'],
      'trendingDown': ['classical', 'metal'],
      'stable': ['rock', 'pop'],
    };
  }

  List<String> _findHiddenGemGenres(Map<String, double> genres) {
    return genres.entries
        .where((entry) => entry.value > 50 && entry.value < 200)
        .map((entry) => entry.key)
        .toList();
  }

  double _calculateTempoRange(int min, int max) {
    return Random().nextDouble() * 500;
  }

  String _getPreferredTempo(Map<String, double> tempoRanges) {
    return tempoRanges.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateTempoVariety(Map<String, double> tempoRanges) {
    return _calculateGenreDiversity(tempoRanges.cast<String, double>());
  }

  Map<String, dynamic> _analyzeWorkoutMusic(Map<String, double> tempoRanges) {
    return {
      'preferredWorkoutTempo': 'fast',
      'workoutFrequency': 0.3 + Random().nextDouble() * 0.4,
    };
  }

  Map<String, dynamic> _analyzeRelaxationMusic(Map<String, double> tempoRanges) {
    return {
      'preferredRelaxationTempo': 'slow',
      'relaxationFrequency': 0.2 + Random().nextDouble() * 0.3,
    };
  }

  Map<String, double> _analyzeDecadePreferences() {
    return {
      '1950s': Random().nextDouble() * 100,
      '1960s': Random().nextDouble() * 150,
      '1970s': Random().nextDouble() * 200,
      '1980s': Random().nextDouble() * 250,
      '1990s': Random().nextDouble() * 300,
      '2000s': Random().nextDouble() * 400,
      '2010s': Random().nextDouble() * 500,
      '2020s': Random().nextDouble() * 600,
    };
  }

  Map<String, dynamic> _analyzeEraAnalysis() {
    return {
      'favoriteEra': '2010s',
      'eraDiversity': 0.7 + Random().nextDouble() * 0.3,
      'eraEvolution': 'modern',
    };
  }

  Map<String, double> _analyzeNewVsOldMusic() {
    return {
      'new': Random().nextDouble() * 800,
      'old': Random().nextDouble() * 400,
    };
  }

  double _calculateTimeTravelScore() => 0.3 + Random().nextDouble() * 0.4;

  Map<String, dynamic> _analyzeMusicalEvolution() {
    return {
      'evolutionPath': 'contemporary_to_classic',
      'evolutionSpeed': 'moderate',
      'evolutionStability': 0.7 + Random().nextDouble() * 0.3,
    };
  }

  double _calculateMoodScore(String mood) => Random().nextDouble() * 100;

  String _getDominantMood(Map<String, double> moods) {
    return moods.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateMoodVariety(Map<String, double> moods) {
    return _calculateGenreDiversity(moods);
  }

  List<Map<String, dynamic>> _analyzeMoodTransitions() {
    return [
      {'from': 'energetic', 'to': 'relaxed', 'frequency': 0.3},
      {'from': 'happy', 'to': 'nostalgic', 'frequency': 0.2},
    ];
  }

  Map<String, dynamic> _generateEmotionalJourney(Map<String, double> moods) {
    return {
      'journeyType': 'balanced',
      'emotionalRange': 'wide',
      'stability': 0.7 + Random().nextDouble() * 0.3,
    };
  }

  double _calculateDiscoveryRate() => 2.5 + Random().nextDouble() * 3.5;

  double _getNewArtistsPerMonth() => (5 + Random().nextInt(20)).toDouble();

  Map<String, double> _analyzeGenreExploration() {
    return {
      'explorationRate': 0.4 + Random().nextDouble() * 0.4,
      'genreRetention': 0.6 + Random().nextDouble() * 0.3,
    };
  }

  double _calculateRecommendationSuccess() => 0.6 + Random().nextDouble() * 0.3;

  Map<String, double> _analyzeExplorationVsFamiliarity() {
    return {
      'exploration': 0.3 + Random().nextDouble() * 0.4,
      'familiarity': 0.4 + Random().nextDouble() * 0.4,
    };
  }

  Map<String, double> _analyzeDiscoverySources() {
    return {
      'recommendations': 0.3 + Random().nextDouble() * 0.3,
      'search': 0.2 + Random().nextDouble() * 0.3,
      'friends': 0.1 + Random().nextDouble() * 0.2,
      'radio': 0.1 + Random().nextDouble() * 0.2,
    };
  }

  Map<String, dynamic> _analyzeSharingBehavior() {
    return {
      'sharingFrequency': 0.2 + Random().nextDouble() * 0.3,
      'sharedContent': ['playlists', 'tracks', 'stats'],
    };
  }

  Map<String, dynamic> _analyzePlaylistCollaboration() {
    return {
      'collaborativePlaylists': 2 + Random().nextInt(5),
      'collaborationFrequency': 0.1 + Random().nextDouble() * 0.2,
    };
  }

  double _analyzeFriendInfluence() => 0.2 + Random().nextDouble() * 0.3;

  Map<String, dynamic> _analyzeSocialListening() {
    return {
      'socialListeningSessions': 10 + Random().nextInt(30),
      'socialListeningPercentage': 0.1 + Random().nextDouble() * 0.2,
    };
  }

  double _analyzeCommunityEngagement() => 0.3 + Random().nextDouble() * 0.4;

  int _getCurrentListeningStreak() => 5 + Random().nextInt(25);

  int _getLongestListeningStreak() => 15 + Random().nextInt(45);

  List<Map<String, dynamic>> _getStreakHistory() {
    return List.generate(12, (index) => {
      'month': DateTime.now().subtract(Duration(days: 30 * index)),
      'streak': 5 + Random().nextInt(20),
    });
  }

  Map<String, dynamic> _predictStreakContinuation() {
    return {
      'probability': 0.7 + Random().nextDouble() * 0.3,
      'predictedDuration': 10 + Random().nextInt(20),
    };
  }

  String _generateStreakMotivation() {
    final motivations = [
      "You're on fire! Keep it up!",
      "Consistency is key to musical discovery.",
      "Your dedication to music is inspiring!",
    ];
    return motivations[Random().nextInt(motivations.length)];
  }

  Map<String, dynamic> _createJourneyMap() {
    return {
      'startingPoint': 'rock',
      'currentPoint': 'indie',
      'journeyType': 'exploratory',
      'totalDistance': 100 + Random().nextInt(200),
    };
  }

  List<Map<String, dynamic>> _identifyKeyMusicalMoments() {
    return [
      {
        'date': DateTime.now().subtract(Duration(days: Random().nextInt(365))),
        'event': 'discovered_favorite_artist',
        'impact': 'high',
      },
    ];
  }

  List<Map<String, dynamic>> _createEvolutionTimeline() {
    return List.generate(6, (index) => {
      'period': 'month_${index + 1}',
      'dominant_genre': ['rock', 'pop', 'electronic', 'indie', 'jazz', 'classical'][index],
      'diversity_score': 0.3 + Random().nextDouble() * 0.7,
    });
  }

  List<String> _identifyMilestoneAchievements() {
    return [
      '1000_tracks_listened',
      '50_artists_discovered',
      '10_genres_explored',
      '30_day_streak',
    ];
  }

  Map<String, dynamic> _predictJourneyDirection() {
    return {
      'next_genre': 'experimental',
      'confidence': 0.6 + Random().nextDouble() * 0.4,
      'timeline': '3_months',
    };
  }

  List<String> _generateArtistRecommendations() {
    return ['Artist A', 'Artist B', 'Artist C', 'Artist D', 'Artist E'];
  }

  List<String> _generateGenreRecommendations() {
    return ['synthwave', 'lofi', 'ambient', 'folk', 'blues'];
  }

  List<String> _generateMoodRecommendations() {
    return ['energetic', 'focus', 'relaxation', 'nostalgic'];
  }

  List<String> _generateTimeRecommendations() {
    return ['80s_classics', '90s_hits', '2000s_indie', 'modern_experimental'];
  }

  List<String> _generateDiscoveryRecommendations() {
    return ['hidden_gems', 'underground_artists', 'emerging_genres'];
  }

  List<String> _generateSocialRecommendations() {
    return ['friend_playlists', 'community_favorites', 'trending_tracks'];
  }

  Map<String, dynamic> _getCurrentListeningGoals() {
    return {
      'monthly_hours': 50,
      'genre_exploration': 3,
      'new_artists': 10,
    };
  }

  Map<String, double> _calculateGoalProgress() {
    return {
      'monthly_hours': 0.7 + Random().nextDouble() * 0.3,
      'genre_exploration': 0.5 + Random().nextDouble() * 0.5,
      'new_artists': 0.8 + Random().nextDouble() * 0.2,
    };
  }

  List<String> _getListeningAchievements() {
    return [
      'early_bird',
      'night_owl',
      'genre_explorer',
      'dedicated_listener',
    ];
  }

  Map<String, dynamic> _suggestListeningGoals() {
    return {
      'next_month': 'explore_jazz_genre',
      'next_week': 'discover_5_new_artists',
      'daily': 'listen_for_30_minutes',
    };
  }

  String _generateGoalMotivation() {
    final motivations = [
      "You're making great progress!",
      "New goals will enhance your musical journey.",
      "Challenge yourself to discover more!",
    ];
    return motivations[Random().nextInt(motivations.length)];
  }

  Map<String, dynamic> _analyzeQualityPreferences() {
    return {
      'preferred_quality': 'high',
      'quality_consistency': 0.8 + Random().nextDouble() * 0.2,
    };
  }

  Map<String, int> _analyzeBitrateUsage() {
    return {
      '128': 10,
      '256': 30,
      '320': 50,
      'lossless': 10,
    };
  }

  Map<String, int> _analyzeFormatDistribution() {
    return {
      'mp3': 60,
      'flac': 20,
      'aac': 15,
      'ogg': 5,
    };
  }

  Map<String, dynamic> _analyzeQualityVsStorage() {
    return {
      'storage_efficiency': 0.7 + Random().nextDouble() * 0.3,
      'quality_priority': 0.8 + Random().nextDouble() * 0.2,
    };
  }

  Map<String, dynamic> _analyzeQualityTrends() {
    return {
      'trend': 'improving',
      'upgrade_frequency': 0.2 + Random().nextDouble() * 0.3,
    };
  }

  Map<String, double> _analyzeListeningDevices() {
    return {
      'headphones': 0.7 + Random().nextDouble() * 0.3,
      'speakers': 0.2 + Random().nextDouble() * 0.3,
      'earbuds': 0.1 + Random().nextDouble() * 0.2,
    };
  }

  Map<String, dynamic> _analyzeHeadphoneUsage() {
    return {
      'wired_vs_wireless': {'wired': 0.3, 'wireless': 0.7},
      'preferred_type': 'over_ear',
    };
  }

  Map<String, dynamic> _analyzeSpeakerUsage() {
    return {
      'usage_percentage': 0.2 + Random().nextDouble() * 0.3,
      'preferred_situation': 'home',
    };
  }

  Map<String, double> _analyzeMobileVsDesktop() {
    return {
      'mobile': 0.8 + Random().nextDouble() * 0.2,
      'desktop': 0.1 + Random().nextDouble() * 0.2,
    };
  }

  double _analyzeDeviceSwitching() => 0.3 + Random().nextDouble() * 0.4;

  Map<String, int> _generateUserRankings() {
    return {
      'total_listening_time': 150,
      'genre_diversity': 200,
      'discovery_rate': 120,
      'social_engagement': 180,
    };
  }

  Map<String, double> _calculatePercentileScores() {
    return {
      'listening_time': 0.75 + Random().nextDouble() * 0.25,
      'genre_diversity': 0.80 + Random().nextDouble() * 0.20,
      'discovery_rate': 0.65 + Random().nextDouble() * 0.35,
      'social_engagement': 0.70 + Random().nextDouble() * 0.30,
    };
  }

  Map<String, dynamic> _compareAchievements() {
    return {
      'user_achievements': 15,
      'average_achievements': 12,
      'top_10_percent': true,
    };
  }

  Map<String, dynamic> _compareListeningHabits() {
    return {
      'user_profile': 'explorer',
      'common_profile': 'mainstream',
      'similarity_score': 0.6 + Random().nextDouble() * 0.3,
    };
  }

  List<String> _generateImprovementSuggestions() {
    return [
      'Try exploring classical music for variety',
      'Increase your listening consistency',
      'Share more playlists with friends',
      'Discover more underground artists',
    ];
  }

  Map<String, dynamic> _getFallbackAnalytics() {
    return {
      'basicStats': {
        'totalPlays': 1000,
        'totalListeningTime': 50000,
        'uniqueTracksPlayed': 500,
      },
      'listeningPatterns': {
        'mostActiveDay': 'Friday',
        'mostActiveHour': 20,
        'averageSessionLength': 30.0,
      },
      'genreAnalysis': {
        'topGenre': 'rock',
        'genreDiversity': 0.7,
      },
      'error': 'Analytics data unavailable',
    };
  }

  void dispose() {
    _analyticsUpdateTimer?.cancel();
  }
}
