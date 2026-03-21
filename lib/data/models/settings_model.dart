enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

enum SettingsType {
  boolean,
  string,
  number,
  selection,
  multiSelection,
  slider,
}

class DownloadModel {
  final String id;
  final String title;
  final String artist;
  final String url;
  final double progress;
  final String size;
  final DownloadStatus status;
  final int createdAt;
  final int? completedAt;

  DownloadModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    this.progress = 0.0,
    this.size = "0 MB",
    this.status = DownloadStatus.pending,
    int? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] as String? ?? "0 MB",
      status: _parseStatus(json['status'] as String?),
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      completedAt: json['completedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'progress': progress,
      'size': size,
      'status': status.name,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  DownloadModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? url,
    double? progress,
    String? size,
    DownloadStatus? status,
    int? createdAt,
    int? completedAt,
  }) {
    return DownloadModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      progress: progress ?? this.progress,
      size: size ?? this.size,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static DownloadStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'paused':
        return DownloadStatus.paused;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      default:
        return DownloadStatus.pending;
    }
  }
}

class UserSettings {
  // Appearance
  final String theme; // dark, light, auto
  final String accentColor; // blue, green, purple, etc.
  final bool useCircularArtistImages;
  final bool showTrackNumbers;
  final bool compactLayout;

  // Audio
  final double volume;
  final bool isMuted;
  final int crossfadeDuration; // milliseconds
  final bool useCrossfade;
  final bool useSilenceSkip;
  final String streamingQuality; // original, compressed

  // Library
  final String defaultView; // albums, artists, folders, playlists
  final bool showAlbumsAsSingles;
  final bool mergeAlbums;
  final List<String> artistSeparators;
  final bool cleanTrackTitles;
  final bool hideRemasteredVersions;

  // Player
  final String repeatMode; // none, one, all
  final bool autoPlay;
  final bool showNowPlayingInTab;
  final bool showLyricsByDefault;

  // Interface
  final bool extendWidth;
  final bool useSidebar;
  final bool showInlineFavoriteIcon;
  final bool highlightFavoriteTracks;

  // Plugins
  final bool useLyricsPlugin;
  final bool autoDownloadLyrics;
  final bool overrideUnsyncedLyrics;

  // Stats & Tracking
  final bool enableTracking;
  final String statsPeriod; // week, month, year, all
  final String statsGroup; // artists, albums, tracks, genres
  final String lastfmApiKey;
  final String lastfmApiSecret;
  final String lastfmSessionKey;

  // Advanced
  final bool enablePeriodicScans;
  final int periodicScanInterval; // seconds
  final bool enableWatchdog;
  final List<String> rootDirectories;

  // Notifications
  final bool enableNotifications;
  final bool showPlayingNotification;
  final bool showControlsInNotification;

  const UserSettings({
    this.theme = 'dark',
    this.accentColor = 'blue',
    this.useCircularArtistImages = true,
    this.showTrackNumbers = true,
    this.compactLayout = false,
    this.volume = 1.0,
    this.isMuted = false,
    this.crossfadeDuration = 1000,
    this.useCrossfade = false,
    this.useSilenceSkip = true,
    this.streamingQuality = 'original',
    this.defaultView = 'albums',
    this.showAlbumsAsSingles = false,
    this.mergeAlbums = false,
    this.artistSeparators = const [],
    this.cleanTrackTitles = true,
    this.hideRemasteredVersions = true,
    this.repeatMode = 'none',
    this.autoPlay = true,
    this.showNowPlayingInTab = true,
    this.showLyricsByDefault = true,
    this.extendWidth = false,
    this.useSidebar = false,
    this.showInlineFavoriteIcon = false,
    this.highlightFavoriteTracks = false,
    this.useLyricsPlugin = false,
    this.autoDownloadLyrics = false,
    this.overrideUnsyncedLyrics = false,
    this.enableTracking = true,
    this.statsPeriod = 'week',
    this.statsGroup = 'artists',
    this.lastfmApiKey = '',
    this.lastfmApiSecret = '',
    this.lastfmSessionKey = '',
    this.enablePeriodicScans = false,
    this.periodicScanInterval = 3600,
    this.enableWatchdog = false,
    this.rootDirectories = const [],
    this.enableNotifications = true,
    this.showPlayingNotification = true,
    this.showControlsInNotification = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: json['theme'] as String? ?? 'dark',
      accentColor: json['accentColor'] as String? ?? 'blue',
      useCircularArtistImages: json['useCircularArtistImages'] as bool? ?? true,
      showTrackNumbers: json['showTrackNumbers'] as bool? ?? true,
      compactLayout: json['compactLayout'] as bool? ?? false,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      isMuted: json['isMuted'] as bool? ?? false,
      crossfadeDuration: json['crossfadeDuration'] as int? ?? 1000,
      useCrossfade: json['useCrossfade'] as bool? ?? false,
      useSilenceSkip: json['useSilenceSkip'] as bool? ?? true,
      streamingQuality: json['streamingQuality'] as String? ?? 'original',
      defaultView: json['defaultView'] as String? ?? 'albums',
      showAlbumsAsSingles: json['showAlbumsAsSingles'] as bool? ?? false,
      mergeAlbums: json['mergeAlbums'] as bool? ?? false,
      artistSeparators: (json['artistSeparators'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      cleanTrackTitles: json['cleanTrackTitles'] as bool? ?? true,
      hideRemasteredVersions: json['hideRemasteredVersions'] as bool? ?? true,
      repeatMode: json['repeatMode'] as String? ?? 'none',
      autoPlay: json['autoPlay'] as bool? ?? true,
      showNowPlayingInTab: json['showNowPlayingInTab'] as bool? ?? true,
      showLyricsByDefault: json['showLyricsByDefault'] as bool? ?? true,
      extendWidth: json['extendWidth'] as bool? ?? false,
      useSidebar: json['useSidebar'] as bool? ?? false,
      showInlineFavoriteIcon: json['showInlineFavoriteIcon'] as bool? ?? false,
      highlightFavoriteTracks: json['highlightFavoriteTracks'] as bool? ?? false,
      useLyricsPlugin: json['useLyricsPlugin'] as bool? ?? false,
      autoDownloadLyrics: json['autoDownloadLyrics'] as bool? ?? false,
      overrideUnsyncedLyrics: json['overrideUnsyncedLyrics'] as bool? ?? false,
      enableTracking: json['enableTracking'] as bool? ?? true,
      statsPeriod: json['statsPeriod'] as String? ?? 'week',
      statsGroup: json['statsGroup'] as String? ?? 'artists',
      lastfmApiKey: json['lastfmApiKey'] as String? ?? '',
      lastfmApiSecret: json['lastfmApiSecret'] as String? ?? '',
      lastfmSessionKey: json['lastfmSessionKey'] as String? ?? '',
      enablePeriodicScans: json['enablePeriodicScans'] as bool? ?? false,
      periodicScanInterval: json['periodicScanInterval'] as int? ?? 3600,
      enableWatchdog: json['enableWatchdog'] as bool? ?? false,
      rootDirectories: (json['rootDirectories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      showPlayingNotification: json['showPlayingNotification'] as bool? ?? true,
      showControlsInNotification: json['showControlsInNotification'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'accentColor': accentColor,
      'useCircularArtistImages': useCircularArtistImages,
      'showTrackNumbers': showTrackNumbers,
      'compactLayout': compactLayout,
      'volume': volume,
      'isMuted': isMuted,
      'crossfadeDuration': crossfadeDuration,
      'useCrossfade': useCrossfade,
      'useSilenceSkip': useSilenceSkip,
      'streamingQuality': streamingQuality,
      'defaultView': defaultView,
      'showAlbumsAsSingles': showAlbumsAsSingles,
      'mergeAlbums': mergeAlbums,
      'artistSeparators': artistSeparators,
      'cleanTrackTitles': cleanTrackTitles,
      'hideRemasteredVersions': hideRemasteredVersions,
      'repeatMode': repeatMode,
      'autoPlay': autoPlay,
      'showNowPlayingInTab': showNowPlayingInTab,
      'showLyricsByDefault': showLyricsByDefault,
      'extendWidth': extendWidth,
      'useSidebar': useSidebar,
      'showInlineFavoriteIcon': showInlineFavoriteIcon,
      'highlightFavoriteTracks': highlightFavoriteTracks,
      'useLyricsPlugin': useLyricsPlugin,
      'autoDownloadLyrics': autoDownloadLyrics,
      'overrideUnsyncedLyrics': overrideUnsyncedLyrics,
      'enableTracking': enableTracking,
      'statsPeriod': statsPeriod,
      'statsGroup': statsGroup,
      'lastfmApiKey': lastfmApiKey,
      'lastfmApiSecret': lastfmApiSecret,
      'lastfmSessionKey': lastfmSessionKey,
      'enablePeriodicScans': enablePeriodicScans,
      'periodicScanInterval': periodicScanInterval,
      'enableWatchdog': enableWatchdog,
      'rootDirectories': rootDirectories,
      'enableNotifications': enableNotifications,
      'showPlayingNotification': showPlayingNotification,
      'showControlsInNotification': showControlsInNotification,
    };
  }

  UserSettings copyWith({
    String? theme,
    String? accentColor,
    bool? useCircularArtistImages,
    bool? showTrackNumbers,
    bool? compactLayout,
    double? volume,
    bool? isMuted,
    int? crossfadeDuration,
    bool? useCrossfade,
    bool? useSilenceSkip,
    String? streamingQuality,
    String? defaultView,
    bool? showAlbumsAsSingles,
    bool? mergeAlbums,
    List<String>? artistSeparators,
    bool? cleanTrackTitles,
    bool? hideRemasteredVersions,
    String? repeatMode,
    bool? autoPlay,
    bool? showNowPlayingInTab,
    bool? showLyricsByDefault,
    bool? extendWidth,
    bool? useSidebar,
    bool? showInlineFavoriteIcon,
    bool? highlightFavoriteTracks,
    bool? useLyricsPlugin,
    bool? autoDownloadLyrics,
    bool? overrideUnsyncedLyrics,
    bool? enableTracking,
    String? statsPeriod,
    String? statsGroup,
    String? lastfmApiKey,
    String? lastfmApiSecret,
    String? lastfmSessionKey,
    bool? enablePeriodicScans,
    int? periodicScanInterval,
    bool? enableWatchdog,
    List<String>? rootDirectories,
    bool? enableNotifications,
    bool? showPlayingNotification,
    bool? showControlsInNotification,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      accentColor: accentColor ?? this.accentColor,
      useCircularArtistImages: useCircularArtistImages ?? this.useCircularArtistImages,
      showTrackNumbers: showTrackNumbers ?? this.showTrackNumbers,
      compactLayout: compactLayout ?? this.compactLayout,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      useCrossfade: useCrossfade ?? this.useCrossfade,
      useSilenceSkip: useSilenceSkip ?? this.useSilenceSkip,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      defaultView: defaultView ?? this.defaultView,
      showAlbumsAsSingles: showAlbumsAsSingles ?? this.showAlbumsAsSingles,
      mergeAlbums: mergeAlbums ?? this.mergeAlbums,
      artistSeparators: artistSeparators ?? this.artistSeparators,
      cleanTrackTitles: cleanTrackTitles ?? this.cleanTrackTitles,
      hideRemasteredVersions: hideRemasteredVersions ?? this.hideRemasteredVersions,
      repeatMode: repeatMode ?? this.repeatMode,
      autoPlay: autoPlay ?? this.autoPlay,
      showNowPlayingInTab: showNowPlayingInTab ?? this.showNowPlayingInTab,
      showLyricsByDefault: showLyricsByDefault ?? this.showLyricsByDefault,
      extendWidth: extendWidth ?? this.extendWidth,
      useSidebar: useSidebar ?? this.useSidebar,
      showInlineFavoriteIcon: showInlineFavoriteIcon ?? this.showInlineFavoriteIcon,
      highlightFavoriteTracks: highlightFavoriteTracks ?? this.highlightFavoriteTracks,
      useLyricsPlugin: useLyricsPlugin ?? this.useLyricsPlugin,
      autoDownloadLyrics: autoDownloadLyrics ?? this.autoDownloadLyrics,
      overrideUnsyncedLyrics: overrideUnsyncedLyrics ?? this.overrideUnsyncedLyrics,
      enableTracking: enableTracking ?? this.enableTracking,
      statsPeriod: statsPeriod ?? this.statsPeriod,
      statsGroup: statsGroup ?? this.statsGroup,
      lastfmApiKey: lastfmApiKey ?? this.lastfmApiKey,
      lastfmApiSecret: lastfmApiSecret ?? this.lastfmApiSecret,
      lastfmSessionKey: lastfmSessionKey ?? this.lastfmSessionKey,
      enablePeriodicScans: enablePeriodicScans ?? this.enablePeriodicScans,
      periodicScanInterval: periodicScanInterval ?? this.periodicScanInterval,
      enableWatchdog: enableWatchdog ?? this.enableWatchdog,
      rootDirectories: rootDirectories ?? this.rootDirectories,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      showPlayingNotification: showPlayingNotification ?? this.showPlayingNotification,
      showControlsInNotification: showControlsInNotification ?? this.showControlsInNotification,
    );
  }
}

class SettingsCategory {
  final String title;
  final String description;
  final String icon;
  final List<SettingItem> settings;

  SettingsCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.settings,
  });
}

class SettingItem {
  final String key;
  final String title;
  final String description;
  final SettingsType type;
  final dynamic value;
  final List<String> options;

  SettingItem({
    required this.key,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.options = const [],
  });
}
