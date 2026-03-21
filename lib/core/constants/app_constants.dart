class AppConstants {
  // App Info
  static const String appName = 'SwingMusic';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String defaultApiUrl = 'http://localhost:1970';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Audio Configuration
  static const Duration audioFadeDuration = Duration(milliseconds: 500);
  static const int maxAudioCacheSize = 100 * 1024 * 1024; // 100MB
  static const String audioCacheKey = 'audio_cache';
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Image Dimensions
  static const double albumArtSize = 56.0;
  static const double largeAlbumArtSize = 200.0;
  static const double artistImageSize = 80.0;
  
  // Storage Keys
  static const String themeKey = 'app_theme';
  static const String authTokenKey = 'auth_token';
  static const String userProfileKey = 'user_profile';
  static const String settingsKey = 'app_settings';
  static const String favoritesKey = 'favorites';
  static const String playlistsKey = 'playlists';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int searchPageSize = 15;
  
  // Audio Quality
  static const Map<String, String> audioQualities = {
    'low': '96kbps',
    'medium': '192kbps',
    'high': '320kbps',
    'lossless': 'FLAC',
  };
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server is temporarily unavailable';
  static const String authErrorMessage = 'Please login to continue';
  static const String genericErrorMessage = 'Something went wrong. Please try again';
  static const String notFoundErrorMessage = 'Resource not found';
  
  // Routes
  static const String homeRoute = '/home';
  static const String libraryRoute = '/library';
  static const String downloadsRoute = '/downloads';
  static const String playerRoute = '/player';
  static const String searchRoute = '/search';
  static const String playlistsRoute = '/playlists';
  static const String settingsRoute = '/settings';
  static const String authRoute = '/auth';
  static const String qrRoute = '/qr';
  static const String offlineRoute = '/offline';
  static const String analyticsRoute = '/analytics';
  static const String profileRoute = '/profile';
}
